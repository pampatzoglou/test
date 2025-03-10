# Control Plane Module

This module manages the lifecycle of Kubernetes control plane nodes with a blue/green deployment strategy for zero-downtime updates.

## Overview

The Control Plane module simulates the deployment and management of Kubernetes control plane nodes across multiple availability zones. It implements a sequential deployment strategy to ensure high availability during updates and provides logging for tracking deployment activities.

## Features

- Multi-AZ deployment for high availability
- Sequential node provisioning and decommissioning
- Automatic AZ switching for master nodes
- Detailed logging of deployment activities
- Support for blue/green deployment strategy

## Requirements

No specific provider requirements. This module uses the `null_resource` to simulate control plane node operations.

## Input Variables

| Name                 | Description                                | Type       | Default | Required |
| -------------------- | ------------------------------------------ | ---------- | ------- | :------: |
| az                   | Deployment Availability Zone               | `string` | n/a     |   yes   |
| next_az              | Next Availability Zone for master failover | `string` | n/a     |   yes   |
| deployment_short_sha | Git short SHA of the deployment            | `string` | n/a     |   yes   |
| previous_sha         | Previous deployment SHA                    | `string` | `""`  |    no    |
| deployment_instances | Number of deployment instances per AZ      | `number` | `2`   |    no    |

## Outputs

| Name              | Description                        |
| ----------------- | ---------------------------------- |
| control_plane_ids | IDs of the control plane instances |

## Usage

```hcl
module "control_plane_A" {
  source = "./modules/control_plane"

  az                   = "locA"
  next_az              = "locB"
  deployment_short_sha = "abc1234"
  previous_sha         = "def5678"  # Optional
  deployment_instances = 2          # Optional
}
```

## How It Works

1. The module creates `null_resource` instances to simulate control plane nodes in the specified availability zone.
2. For the first instance in each AZ, it simulates moving the master role to the next AZ for high availability.
3. Each node logs its lifecycle events (creation, initialization, etcd sync, etc.) to individual log files.
4. When destroying nodes (either through `terraform destroy` or reducing instance count), it simulates a graceful decommissioning process.

## Integration with Main Configuration

This module is typically used in pairs to manage control plane nodes across two availability zones:

```hcl
module "control_plane_A" {
  source     = "./modules/control_plane"
  depends_on = [null_resource.control_plane_backup]

  az                   = local.deployment_az[0]
  next_az              = local.az_map[local.deployment_az[0]]
  deployment_short_sha = local.deployment_short_sha
  previous_sha         = local.previous_sha
  deployment_instances = local.deployment_instances
}

module "control_plane_B" {
  source     = "./modules/control_plane"
  depends_on = [module.control_plane_A]

  az                   = local.deployment_az[1]
  next_az              = local.az_map[local.deployment_az[1]]
  deployment_short_sha = local.deployment_short_sha
  previous_sha         = local.previous_sha
  deployment_instances = local.deployment_instances
}
```

## Logging

The module creates detailed logs for each control plane node:

1. Individual node logs in `logs/{instance_id}.log`
2. Deployment-wide logs in `logs/deployment.log`

These logs track the lifecycle of each node, including:

- Node creation and initialization
- etcd cluster synchronization
- AZ switching operations
- Node decommissioning

## Notes

- This module uses `null_resource` with `local-exec` provisioners to simulate control plane operations.
- The `always_run` trigger ensures that the resources are evaluated on every apply.
- The `create_before_destroy` lifecycle setting ensures proper sequencing during updates.
