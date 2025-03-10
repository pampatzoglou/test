variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
}

variable "environment" {
  description = "Environment type (basic, staging, prod)"
  type        = string
  default     = "basic"
  validation {
    condition     = contains(["basic", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: basic, staging, prod"
  }
}

variable "deployments" {
  type = list(object({
    name       = string
    namespace  = string
    chart_name = string
  }))
  default = [
    { name = "argocd", namespace = "argocd", chart_name = "argo-cd" },
    { name = "kyverno", namespace = "kyverno", chart_name = "kyverno" },
    { name = "kyverno-policies", namespace = "kyverno", chart_name = "kyverno-policies" },
  ]
  description = "List of Helm charts to deploy with their respective namespaces and chart names"
}

variable "namespace_labels" {
  description = "Default labels for namespaces"
  type        = map(string)
  default = {
    monitoring              = "enabled"
    "prometheus.io/monitor" = "true"
    team                    = "infrastructure"
    "security-level"        = "high"
    "terraform-managed"     = "true"
    "resources.quota"       = "enabled"
  }
}

variable "namespace_annotations" {
  description = "Default annotations for namespaces"
  type        = map(string)
  default = {
    "terraform.io/managed"                           = "true"
    "pod-security.kubernetes.io/enforce"             = "restricted"
    "pod-security.kubernetes.io/audit"               = "baseline"
    "pod-security.kubernetes.io/warn"                = "restricted"
    "kubernetes.io/service-account-token-expiration" = "3600"
    "backup.velero.io/backup"                        = "true"
    "compliance.level"                               = "SOX"
    "policies.kyverno.io/enforce"                    = "false"
  }
}

variable "argocd_app_of_apps_repos" {
  description = "List of Git repositories to be managed by ArgoCD in an app of apps pattern"
  type = list(object({
    name             = string      # Application name
    repo_url         = string      # Git repository URL
    path             = string      # Path within the repository
    target_revision  = string      # Git revision (branch, tag, commit)
    namespace        = string      # Target namespace
    create_namespace = bool        # Whether to create the namespace
    values           = map(string) # Optional values to override
  }))
  default = []
}
