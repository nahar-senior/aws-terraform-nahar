# Databricks on AWS with Terraform

A production-ready Terraform configuration implementing the two-stage deployment pattern for Databricks on AWS with Unity Catalog support.

## Architecture

This repository solves the "chicken and egg" problem with Databricks provider configuration by implementing a two-stage deployment pattern:

- **Stage 1 (base-infra)**: AWS infrastructure + Databricks workspace creation
- **Stage 2 (workspace-infra)**: Workspace-level resources using remote state

### Two-Stage Deployment Pattern

The two-stage approach is necessary because:
1. Databricks workspace URL is required to configure the workspace provider
2. Workspace URL is only available after workspace creation
3. Single-stage deployment creates circular dependency issues

This pattern uses Terraform remote state to pass outputs between stages, ensuring proper provider configuration timing.

## Repository Structure

```
├── base-infra/              # Stage 1: Account-level infrastructure
│   ├── aws-infra/           # AWS infrastructure (VPC, S3, IAM)
│   ├── databricks-infra/    # Databricks workspace and Unity Catalog
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
│
└── workspace-infra/         # Stage 2: Workspace-level resources
    ├── cluster-management/  # Databricks clusters
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── terraform.tfvars.example
```

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- Databricks Account Admin access
- Service Principal with Account Admin permissions

## Deployment Instructions

### Stage 1: Deploy Base Infrastructure

1. **Configure variables**
   ```bash
   cd base-infra/
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Deploy infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Stage 2: Deploy Workspace Infrastructure

3. **Configure workspace variables**
   ```bash
   cd ../workspace-infra/
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Deploy workspace resources**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

### Required Variables

#### Base Infrastructure (Stage 1)
- `databricks_account_id`: Your Databricks Account ID
- `client_id`: Service Principal Client ID for account-level operations
- `client_secret`: Service Principal Client Secret
- `region`: AWS region for deployment (default: us-west-2)

#### Workspace Infrastructure (Stage 2)
- `client_id`: Service Principal Client ID for workspace-level operations
- `client_secret`: Service Principal Client Secret

### Optional Variables

- `cidr_block`: VPC CIDR block (default: 10.0.0.0/16)
- `tags`: Resource tags for organization and cost tracking

## Infrastructure Components

### AWS Infrastructure
- VPC with public and private subnets across multiple AZs
- NAT Gateway for private subnet internet access
- VPC Endpoints for S3, STS, and Kinesis
- IAM cross-account role for Databricks
- S3 bucket for root storage with encryption

### Databricks Infrastructure
- Databricks workspace with Unity Catalog
- Metastore creation and assignment
- Network configuration for workspace
- Storage configuration for root bucket

### Workspace Resources
- Unity Catalog compatible cluster
- Auto-scaling configuration (1-3 workers)
- Latest LTS Databricks Runtime
- Proper data security mode for Unity Catalog

## Security Considerations

- All sensitive files are excluded via .gitignore
- Service Principal credentials should be stored securely
- State files are excluded from version control
- Resources are tagged for cost tracking and compliance

## State Management

- Each stage maintains its own Terraform state
- Stage 2 references Stage 1 outputs via remote state
- State files should be stored in secure backend (S3, Azure Storage, etc.)

## Troubleshooting

### Common Issues

1. **Provider Configuration Error**: Ensure Stage 1 is deployed before Stage 2
2. **Authentication Error**: Verify Service Principal credentials and permissions
3. **Resource Conflicts**: Check for existing resources with same names

### State Management

- Each stage maintains its own Terraform state
- Stage 2 references Stage 1 outputs via remote state
- State files should be stored in secure backend (S3, Azure Storage, etc.)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This code is provided for educational and demonstration purposes. It should not be used in production without proper security review and testing. The authors are not responsible for any security issues or costs incurred from using this code.