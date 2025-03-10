# Namespace Config Module

This module manages Kubernetes namespaces with proper labels, annotations, and resource quotas.

## Features

- **Namespace Management**: Creates and configures Kubernetes namespaces
- **Label Management**: Applies consistent labels to namespaces
- **Annotation Management**: Applies consistent annotations to namespaces
- **Resource Quotas**: Configures resource quotas for namespaces
- **Environment-specific Configuration**: Supports different configurations for different environments

## Usage

```hcl
module "namespace_config" {
  source = "./modules/namespace_config"

  kubeconfig_path = "~/.kube/config"
  environment     = "prod"

  namespaces = [
    {
      name        = "application"
      labels      = { "app.kubernetes.io/name" = "application" }
      annotations = { "linkerd.io/inject" = "enabled" }
      quota       = {
        cpu    = "4"
        memory = "8Gi"
      }
    }
  ]
}
```

## How It Works

The module uses Terraform's Kubernetes provider to manage namespaces:

1. **Namespace Creation**:
   - Namespaces are created with the specified names
   - Labels and annotations are applied to the namespaces

2. **Resource Quotas**:
   - Resource quotas are created for each namespace
   - Quotas can be customized for each namespace

3. **Environment-specific Configuration**:
   - Different configurations can be applied based on the environment
   - This allows for different resource allocations in different environments

## Implementation Details

- **Namespace Lifecycle**: Namespaces are created and managed by Terraform
- **Label Consistency**: Labels are applied consistently across namespaces
- **Annotation Consistency**: Annotations are applied consistently across namespaces
- **Resource Allocation**: Resource quotas are configured based on environment and namespace requirements
