terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

resource "null_resource" "helm_release_trigger" {
  triggers = {
    # Track changes to chart file
    chart_checksum = fileexists(var.chart) ? filesha256(var.chart) : "chart_not_found"
    # Track changes to values files
    values_checksum = var.values_files != null ? sha256(join(",", [
      for f in var.values_files :
      fileexists(f) ? filesha256(f) : "file_not_found"
    ])) : "no_values"
    # Track changes to release configuration
    release_name  = var.release_name
    chart_version = var.chart_version != null ? var.chart_version : "none"
  }
}

resource "helm_release" "release" {
  name             = var.release_name
  replace          = true # This ensures proper replacement of existing releases
  repository       = var.repository_url
  chart            = var.chart
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = var.create_namespace
  timeout          = var.timeout
  atomic           = var.atomic
  cleanup_on_fail  = var.cleanup_on_fail
  wait             = var.wait
  wait_for_jobs    = var.wait_for_jobs
  force_update     = var.force_update
  recreate_pods    = var.recreate_pods # Recreate pods during upgrade

  lifecycle {
    prevent_destroy       = false
    create_before_destroy = true
    ignore_changes = [
      values,
      set,
      set_sensitive
    ]
    replace_triggered_by = [null_resource.helm_release_trigger]
  }

  dynamic "set" {
    for_each = var.set_values
    content {
      name  = set.key
      value = set.value
    }
  }

  values = var.values_files != null ? [
    for f in var.values_files :
    fileexists(f) ? file(f) : ""
  ] : []
}
