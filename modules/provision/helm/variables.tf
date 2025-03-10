variable "environment" {
  description = "Environment type (basic, staging, prod)"
  type        = string
  default     = "basic"
  validation {
    condition     = contains(["basic", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: basic, staging, prod"
  }
}

variable "release_name" {
  description = "Name of the Helm release"
  type        = string
}

variable "repository_url" {
  description = "URL of the Helm chart repository"
  type        = string
  default     = null
}

variable "chart" {
  description = "Path to the Helm chart or chart name"
  type        = string
}

variable "chart_version" {
  description = "Version of the Helm chart"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Kubernetes namespace to install the release into"
  type        = string
}

variable "create_namespace" {
  description = "Create the namespace if it does not exist"
  type        = bool
  default     = true
}

variable "timeout" {
  description = "Time in seconds to wait for any individual Kubernetes operation"
  type        = number
  default     = 600
}

variable "atomic" {
  description = "If set, installation process rolls back changes made in case of failed installation"
  type        = bool
  default     = true
}

variable "cleanup_on_fail" {
  description = "Allow deletion of new resources created in this upgrade when upgrade fails"
  type        = bool
  default     = true
}

variable "wait" {
  description = "Will wait until all resources are in a ready state before marking the release as successful"
  type        = bool
  default     = true
}

variable "wait_for_jobs" {
  description = "If wait is enabled, will wait until all Jobs have been completed before marking the release as successful"
  type        = bool
  default     = true
}

variable "force_update" {
  description = "Force resource update through delete/recreate if needed"
  type        = bool
  default     = false
}

variable "recreate_pods" {
  description = "Recreate pods during upgrade"
  type        = bool
  default     = false
}

variable "set_values" {
  description = "Map of value assignments for Helm chart"
  type        = map(string)
  default     = {}
}

variable "values_files" {
  description = "List of paths to values files for the Helm chart"
  type        = list(string)
  default     = null
}
