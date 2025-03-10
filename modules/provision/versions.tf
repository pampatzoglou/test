locals {
  # Define chart versions for each environment
  chart_versions = {
    # Default/basic environment versions
    basic = {
      argocd                   = "7.7.16"
      kyverno                  = "3.3.4"
      "kyverno-policies"       = "3.3.2"
      prometheus_operator_crds = "17.0.2"
    }

    # Staging environment versions
    staging = {
      argocd                   = "7.7.16" # Same as basic for now
      kyverno                  = "3.3.4"  # Same as basic for now
      "kyverno-policies"       = "3.3.2"  # Same as basic for now
      prometheus_operator_crds = "17.0.2" # Same as basic for now
    }

    # Production environment versions
    prod = {
      argocd                   = "7.7.16" # Same as basic for now
      kyverno                  = "3.3.4"  # Same as basic for now
      "kyverno-policies"       = "3.3.2"  # Same as basic for now
      prometheus_operator_crds = "17.0.2" # Same as basic for now
    }
  }

  # Get the effective chart versions for the current environment
  effective_chart_versions = local.chart_versions[var.environment]

  # All chart versions across all environments (for chart downloading)
  all_chart_versions = distinct(flatten([
    for chart in ["argocd", "kyverno", "kyverno-policies", "prometheus_operator_crds"] : [
      for env in ["basic", "staging", "prod"] : {
        name    = chart
        version = local.chart_versions[env][chart]
      }
    ]
  ]))

  # Chart repositories
  chart_repositories = {
    argocd                   = "https://argoproj.github.io/argo-helm"
    kyverno                  = "https://kyverno.github.io/kyverno"
    "kyverno-policies"       = "https://kyverno.github.io/kyverno"
    prometheus_operator_crds = "https://prometheus-community.github.io/helm-charts"
  }
}
