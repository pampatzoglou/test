terraform {
  backend "local" {}

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.4.0"
    }
  }
  required_version = ">= 1.0"
}

# Provider configurations
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


# provider "kubernetes" {
#   config_path = var.kubeconfig_path
# }
