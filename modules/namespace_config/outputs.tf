output "namespace" {
  description = "The name of the namespace"
  value       = local.namespace
}

output "resource_quota" {
  description = "The resource quota configuration applied"
  value       = kubernetes_resource_quota.quota
}

output "limit_range" {
  description = "The limit range configuration applied"
  value       = kubernetes_limit_range.limits
}
