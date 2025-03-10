# Provision K8s Module

This module handles the provisioning of Kubernetes resources using Helm charts. It implements a GitOps approach with ArgoCD for continuous delivery.

## Features

- **Helm Chart Management**: Deploys and manages Helm charts with proper versioning
- **ArgoCD Integration**: Sets up ArgoCD for GitOps-based deployments
- **Policy Management**: Installs and configures Kyverno for policy enforcement
- **Monitoring**: Installs Prometheus CRDs for monitoring
- **Environment-specific Configuration**: Supports different configurations for different environments

## Usage

```hcl
module "provision" {
  source = "./modules/provision_k8s"

  kubeconfig_path          = "~/.kube/config"
  environment              = "prod"
  argocd_app_of_apps_repos = var.argocd_app_of_apps_repos

  depends_on = [
    module.control_nodes
  ]
}
```

## How It Works

The module uses Terraform's Helm provider to deploy and manage Helm charts:

1. **Chart Versioning**:
   - Chart versions are defined in `versions.tf`
   - Different versions can be used for different environments

2. **ArgoCD App of Apps Pattern**:
   - ArgoCD is configured to manage applications in a GitOps manner
   - The "App of Apps" pattern is used to manage multiple applications

3. **Kyverno Policies**:
   - Kyverno is installed for policy management
   - Policies are defined as Kubernetes resources

4. **Prometheus CRDs**:
   - Prometheus CRDs are installed for monitoring
   - These CRDs are used by the monitoring stack

## Implementation Details

- **Local Helm Charts**: Helm charts are stored locally in the `resources` directory
- **Chart Updates**: Charts can be updated using the `update_charts.sh` script
- **Namespace Management**: Namespaces are created with proper labels and annotations
- **Resource Dependencies**: Resources are created in the correct order with proper dependencies
