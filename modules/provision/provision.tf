module "prometheus-crds" {
  source       = "./helm"
  release_name = "prometheus-crds"
  # Use local chart file with version from centralized config
  chart           = "${path.module}/resources/monitoring/prometheus-operator-crds-${local.effective_chart_versions.prometheus_operator_crds}.tgz"
  namespace       = "monitoring"
  atomic          = true
  cleanup_on_fail = true
  wait            = true
  wait_for_jobs   = true
  force_update    = true # Enable server-side apply for CRDs


  depends_on = [
    kubernetes_namespace.deployment_namespace
  ]
}

resource "kubernetes_namespace" "deployment_namespace" {
  for_each = { for deployment in var.deployments : deployment.namespace => deployment... }

  metadata {
    name        = each.key
    labels      = var.namespace_labels
    annotations = var.namespace_annotations
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels["kubectl.kubernetes.io/last-applied-configuration"]
    ]
  }
}

# Deploy other charts
module "deployments" {
  for_each = {
    for deployment in var.deployments : deployment.name => deployment
  }

  source = "./helm"

  release_name     = each.value.name
  namespace        = each.value.namespace
  create_namespace = false

  # Use local chart file with version from centralized config
  chart = "${path.module}/resources/${each.value.namespace}/${each.value.chart_name}-${lookup(local.effective_chart_versions, each.value.name, "latest")}.tgz"

  # Dynamically include values files only if they exist
  values_files = compact([
    fileexists("${path.module}/resources/${each.value.namespace}/values.yaml") ? "${path.module}/resources/${each.value.namespace}/values.yaml" : "",
    fileexists("${path.module}/resources/${each.value.namespace}/values-${var.environment == "basic" ? "dev" : var.environment}.yaml") ? "${path.module}/resources/${each.value.namespace}/values-${var.environment == "basic" ? "dev" : var.environment}.yaml" : ""
  ])

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  wait_for_jobs   = true
  force_update    = true

  depends_on = [
    module.prometheus-crds,
    kubernetes_namespace.deployment_namespace
  ]
}

# # Create ArgoCD Application resources for app of apps pattern
# resource "kubernetes_manifest" "argocd_applications" {
#   for_each = { for repo in var.argocd_app_of_apps_repos : repo.name => repo }

#   manifest = {
#     apiVersion = "argoproj.io/v1alpha1"
#     kind       = "Application"
#     metadata = {
#       name      = each.value.name
#       namespace = "argocd"
#     }
#     spec = {
#       project = "default"
#       source = {
#         repoURL        = each.value.repo_url
#         targetRevision = each.value.target_revision
#         path           = each.value.path
#       }
#       destination = {
#         server    = "https://kubernetes.default.svc"
#         namespace = each.value.namespace
#       }
#       syncPolicy = {
#         automated = {
#           prune    = true
#           selfHeal = true
#         }
#         syncOptions = [
#           "CreateNamespace=${each.value.create_namespace}"
#         ]
#       }
#     }
#   }

#   depends_on = [
#     module.deployments
#   ]
# }
