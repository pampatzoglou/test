# Infrastructure Base

This project provides a modular Terraform infrastructure for provisioning and managing Kubernetes clusters across different environments (basic, staging, production). It uses Terraform workspaces to manage environment-specific configurations and implements a GitOps approach with ArgoCD for continuous delivery.

## Architecture Overview

The infrastructure consists of several key components:

- **Control Plane Module**: Manages the Kubernetes control plane nodes
- **Provision K8s Module**: Handles Kubernetes resource provisioning using Helm charts
- **Namespace Configuration**: Manages Kubernetes namespaces with proper labels and annotations
- **GitOps with ArgoCD**: Implements the "App of Apps" pattern for managing applications

For a detailed architecture description, see [Architecture Documentation](docs/architecture.md).

## Prerequisites

- Terraform v1.0.0+
- kubectl configured with access to your target cluster
- Helm v3.0.0+

## Usage

### Environment Setup

#### Setup devbox

`curl -fsSL https://get.jetify.com/devbox | bash`

Alternative visit [install documentation](https://jetify-com.vercel.app/docs/devbox/installing_devbox/)

#### How to use

```bash
devbox shell
just
```

## Configuration

### ArgoCD App of Apps Configuration

The infrastructure supports the ArgoCD "App of Apps" pattern for GitOps deployment:

```hcl
argocd_app_of_apps_repos = [
  {
    name             = "my-app"
    repo_url         = "https://github.com/org/repo.git"
    path             = "apps"
    target_revision  = "main"
    namespace        = "my-namespace"
    create_namespace = true
    values           = {
      "key" = "value"
    }
  }
]
```

## Modules

### Control Nodes Module

Manages the lifecycle of Kubernetes control plane nodes with blue/green deployment strategy for zero-downtime updates. See [Control Nodes README](modules/control_plane/README.md) for details.

### Provision K8s Module

Handles the provisioning of Kubernetes resources using Helm charts

### Namespace Config Module

Manages Kubernetes namespaces with proper labels, annotations, and resource quotas.
