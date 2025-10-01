# Databricks Workspace Infrastructure

This directory contains Terraform configurations for deploying workspace-level resources within a Databricks workspace. It is designed to be deployed as **Stage 2** of a two-stage deployment, following the successful deployment of the `base-infra` stage.

## Structure

```
├── cluster-management/  # Databricks clusters
├── main.tf              # Root module for workspace-level orchestration
├── variables.tf         # Input variables for this stage
├── outputs.tf           # Output values from this stage
└── terraform.tfvars.example # Example configuration for variables
```

## Quick Start

1. **Ensure `base-infra` is deployed**: This stage relies on the `base-infra` stage having been successfully deployed and its `terraform.tfstate` file being available.

2. **Configure your variables**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your Databricks Service Principal credentials
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Deploy the workspace resources**:
   ```bash
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

- `client_id`: Databricks service principal client ID for workspace-level operations.
- `client_secret`: Databricks service principal secret for workspace-level operations.

### Optional Variables

- `tags`: Resource tags.

## Security

- Uses Databricks Service Principal for authentication.
- Sensitive credentials are excluded via `.gitignore`.

## Documentation

For detailed configuration options and best practices, see the individual module documentation in the `cluster-management/` directory.
