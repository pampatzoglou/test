variable "az" {
  description = "Deployment Availability Zone"
  type        = string
}

variable "next_az" {
  description = "Next Availability Zone"
  type        = string
}

variable "deployment_short_sha" {
  description = "Git short SHA of the deployment"
  type        = string
}

variable "previous_sha" {
  description = "Previous deployment SHA"
  type        = string
  default     = ""
}

variable "deployment_instances" {
  description = "Number of deployment instances"
  type        = number
  default     = 2
}

locals {
  az                   = var.az
  next_az              = var.next_az
  deployment_short_sha = var.deployment_short_sha
  previous_sha         = var.previous_sha
  deployment_instances = var.deployment_instances
}

# Control Plane Task for a single AZ
resource "null_resource" "control_plane" {
  count = local.deployment_instances

  triggers = {
    always_run  = timestamp() # Forces the resource to run on every apply
    instance_id = "control-node-${local.az}-${local.deployment_short_sha}-${count.index}"
  }

  lifecycle {
    create_before_destroy = true
  }

  # Only the first instance in each AZ handles the AZ switching
  provisioner "local-exec" {
    command = <<EOF
      if [ ${count.index} -eq 0 ]; then
        date +'%Y-%m-%d %H:%M:%S.%N - Processing AZ: ${local.az}, moving master to next AZ: ${local.next_az}' >> logs/deployment.log
        sleep 5
        date +'%Y-%m-%d %H:%M:%S.%N - Master now in AZ: ${local.next_az}' >> logs/deployment.log
      fi
    EOF
  }

  # Create timestamp when the resource is created
  provisioner "local-exec" {
    when    = create
    command = <<EOF
      date +'%Y-%m-%d %H:%M:%S.%N - Creating: ${self.triggers.instance_id}' > logs/${self.triggers.instance_id}.log
      date +'%Y-%m-%d %H:%M:%S.%N - Initializing new control plane node...' >> logs/${self.triggers.instance_id}.log
      sleep 5
      date +'%Y-%m-%d %H:%M:%S.%N - Waiting for etcd cluster to sync...' >> logs/${self.triggers.instance_id}.log
      date +'%Y-%m-%d %H:%M:%S.%N - Node ${self.triggers.instance_id} state changed to READY' >> logs/${self.triggers.instance_id}.log
    EOF
  }

  # This will only run when explicitly destroying resources (terraform destroy)
  # or when reducing instance count
  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      date +'%Y-%m-%d %H:%M:%S.%N - Starting teardown of ${self.triggers.instance_id}' >> logs/${self.triggers.instance_id}.log
      sleep 5
      date +'%Y-%m-%d %H:%M:%S.%N - Node ${self.triggers.instance_id} state changed to DECOMMISSIONED' >> logs/${self.triggers.instance_id}.log
    EOF
  }
}

output "control_plane_ids" {
  description = "IDs of the control plane instances"
  value       = [for instance in null_resource.control_plane : instance.triggers.instance_id]
}
