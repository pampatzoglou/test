output "release_name" {
  description = "The name of the Helm release"
  value       = var.release_name
}

output "release_namespace" {
  description = "The namespace of the Helm release"
  value       = var.namespace
}

output "release_status" {
  description = "The status of the Helm release"
  value       = try(helm_release.release.status, "existing")
}

output "release_metadata" {
  description = "The metadata block of the Helm release"
  value       = try(helm_release.release.metadata, {})
}

output "namespace_id" {
  description = "The namespace where the helm release is installed"
  value       = helm_release.release.namespace
}
