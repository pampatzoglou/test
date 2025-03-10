# List available commands
default:
    @just --list

# Format all Terraform code
fmt:
    terraform fmt -recursive

# Init terraform providers with local backend (default)
init:
    terraform init -backend-config=backend-local.hcl

# Init terraform providers with cloud resources
init-cloud:
    terraform init -backend-config=backend-staging.hcl
    terraform init -backend-config=backend-production.hcl

# Run static tests
lint:
    terraform validate

# Test infra
test:
    terraform test

# Apply
apply:
    just lint
    terraform apply -auto-approve
    just test
