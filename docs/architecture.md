# Infrastructure Architecture

This document describes the architecture of the Kubernetes infrastructure provisioning system.

## Overview

The infrastructure is managed using Terraform and consists of modules for provisioning Kubernetes resources using Helm charts. The system supports different environments (basic, staging, production) with environment-specific configurations.

## Architecture Diagram

```mermaid
flowchart TB
    subgraph "Root Configuration"
        main["main.tf\n(Root Configuration)"]
        vars["variables.tf\n(Root Variables)"]
    end

    subgraph "Provision K8s Module"
        provision["provision.tf\n(Main Provisioning Logic)"]
        versions["versions.tf\n(Chart Versions)"]
        prov_vars["variables.tf\n(Module Variables)"]
    end

    subgraph "Helm Module"
        helm_main["main.tf\n(Helm Release Logic)"]
        helm_vars["variables.tf\n(Helm Variables)"]
    end

    subgraph "Kubernetes Resources"
        prometheus["Prometheus CRDs"]
        kyverno["Kyverno"]
        kyverno_policies["Kyverno Policies"]
        argocd["ArgoCD"]
        namespaces["Kubernetes Namespaces"]
    end

    subgraph "Scripts"
        update_charts["update_charts.sh\n(Chart Downloader)"]
    end

    subgraph "Chart Resources"
        charts["Local Helm Charts\n(.tgz files)"]
    end

    main --> provision
    vars --> main

    provision --> helm_main
    versions --> provision
    prov_vars --> provision

    helm_vars --> helm_main

    helm_main --> prometheus
    helm_main --> kyverno
    helm_main --> kyverno_policies
    helm_main --> argocd

    provision --> namespaces

    update_charts --> charts
    charts --> helm_main

    classDef terraform fill:#844FBA,color:white;
    classDef kubernetes fill:#326CE5,color:white;
    classDef helm fill:#0F1689,color:white;
    classDef script fill:#F7DF1E,color:black;

    class main,vars,provision,versions,prov_vars,helm_main,helm_vars terraform;
    class prometheus,kyverno,kyverno_policies,argocd,namespaces kubernetes;
    class charts helm;
    class update_charts script;
```

## Component Description

### Root Configuration
- **main.tf**: Defines the Terraform providers (Kubernetes, Helm, Null, Talos) and calls the provision_k8s module
- **variables.tf**: Defines input variables for the root module, including environment type and kubeconfig path

### Provision K8s Module
- **provision.tf**: Main logic for provisioning Kubernetes resources, including namespaces and Helm releases
- **versions.tf**: Defines chart versions for different environments
- **variables.tf**: Defines input variables for the provision_k8s module

### Helm Module
- **main.tf**: Implements the Helm release resource with proper lifecycle management
- **variables.tf**: Defines input variables for the Helm module

### Kubernetes Resources
- **Namespaces**: Created for each deployment with proper labels and annotations
- **Prometheus CRDs**: Custom Resource Definitions for Prometheus monitoring
- **Kyverno**: Policy management engine for Kubernetes
- **Kyverno Policies**: Policies for Kyverno
- **ArgoCD**: GitOps continuous delivery tool for Kubernetes

### Scripts
- **update_charts.sh**: Downloads Helm charts from repositories and saves them locally

### Chart Resources
- Local Helm chart files (.tgz) stored in the resources directory
