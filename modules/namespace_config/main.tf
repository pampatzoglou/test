terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.19"
    }
  }
}

variable "namespace" {
  description = "The namespace to configure"
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

variable "create_namespace" {
  description = "Whether to create the namespace or use existing"
  type        = bool
  default     = false
}

# Either create a new namespace or use existing one
resource "kubernetes_namespace" "namespace" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
  }
}

# Data source for existing namespace
data "kubernetes_namespace" "existing" {
  count = var.create_namespace ? 0 : 1

  metadata {
    name = var.namespace
  }
}

locals {
  namespace = var.create_namespace ? kubernetes_namespace.namespace[0].metadata[0].name : data.kubernetes_namespace.existing[0].metadata[0].name

  # Define environment-specific resource quotas
  resource_quotas = {
    basic = {
      requests_cpu    = "2"
      requests_memory = "4Gi"
      limits_cpu      = "4"
      limits_memory   = "8Gi"
      pods            = "10"
    }
    staging = {
      requests_cpu    = "4"
      requests_memory = "8Gi"
      limits_cpu      = "8"
      limits_memory   = "16Gi"
      pods            = "20"
    }
    prod = {
      requests_cpu    = "8"
      requests_memory = "16Gi"
      limits_cpu      = "16"
      limits_memory   = "32Gi"
      pods            = "40"
    }
  }

  # Define environment-specific limit ranges
  limit_ranges = {
    basic = {
      default_request_cpu    = "100m"
      default_request_memory = "128Mi"
      default_limit_cpu      = "300m"
      default_limit_memory   = "256Mi"
    }
    staging = {
      default_request_cpu    = "200m"
      default_request_memory = "256Mi"
      default_limit_cpu      = "500m"
      default_limit_memory   = "512Mi"
    }
    prod = {
      default_request_cpu    = "500m"
      default_request_memory = "512Mi"
      default_limit_cpu      = "1"
      default_limit_memory   = "1Gi"
    }
  }
}

# Resource Quota
resource "kubernetes_resource_quota" "quota" {
  metadata {
    name      = "${local.namespace}-quota"
    namespace = local.namespace
  }

  spec {
    hard = {
      "requests.cpu"    = local.resource_quotas[var.environment].requests_cpu
      "requests.memory" = local.resource_quotas[var.environment].requests_memory
      "limits.cpu"      = local.resource_quotas[var.environment].limits_cpu
      "limits.memory"   = local.resource_quotas[var.environment].limits_memory
      "pods"            = local.resource_quotas[var.environment].pods
    }
  }
}

# Limit Range
resource "kubernetes_limit_range" "limits" {
  metadata {
    name      = "${local.namespace}-limits"
    namespace = local.namespace
  }

  spec {
    limit {
      type = "Container"
      default_request = {
        cpu    = local.limit_ranges[var.environment].default_request_cpu
        memory = local.limit_ranges[var.environment].default_request_memory
      }
      default = {
        cpu    = local.limit_ranges[var.environment].default_limit_cpu
        memory = local.limit_ranges[var.environment].default_limit_memory
      }
    }
  }
}
