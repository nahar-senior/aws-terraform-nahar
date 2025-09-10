# Databricks on AWS - Terraform Infrastructure

This repository contains Terraform modules for deploying a complete Databricks workspace on AWS with Unity Catalog support.

## 🏗️ Architecture

The infrastructure consists of two main modules:

### 1. Base Infrastructure (`modules/base_infra/`)
- **VPC**: Custom VPC with public and private subnets
- **Security**: Security groups with Databricks-optimized rules
- **Storage**: S3 bucket for Databricks root storage with encryption
- **IAM**: Cross-account role for Databricks integration
- **VPC Endpoints**: Cost-optimized endpoints for S3, STS, EC2, ELB, Kinesis, and CloudWatch Logs

### 2. Databricks Workspace (`modules/databricks_workspace/`)
- **Workspace**: ENTERPRISE-tier Databricks workspace
- **Unity Catalog**: Integration with existing metastore
- **Network Configuration**: Links VPC to Databricks
- **Storage Configuration**: Links S3 bucket to Databricks
- **Credentials Configuration**: Links IAM role to Databricks

## 🚀 Deployment

### Prerequisites
- AWS CLI configured with appropriate permissions
- Databricks CLI configured with OAuth
- Terraform >= 1.0

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd aws-terraform-nahar
   ```

2. **Configure variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Authenticate to Databricks**
   ```bash
   databricks auth login --host https://accounts.cloud.databricks.com --account-id YOUR_ACCOUNT_ID
   ```

4. **Deploy infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## 📋 Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `databricks_account_id` | Your Databricks Account ID | `"12345678-1234-1234-1234-123456789012"` |
| `existing_metastore_id` | Unity Catalog Metastore ID | `"a1b2c3d4-e5f6-7890-abcd-ef1234567890"` |
| `prefix` | Resource naming prefix | `"my-databricks"` |
| `aws_region` | AWS deployment region | `"us-west-2"` |

## 🔒 Security

- All sensitive values are in `terraform.tfvars` (not committed to Git)
- Uses OAuth authentication (no hardcoded tokens)
- VPC endpoints reduce data transfer costs and enhance security
- Private subnets for Databricks clusters

## 📊 Resources Created

- **AWS Resources**: ~30 resources including VPC, subnets, security groups, S3 bucket, IAM roles, VPC endpoints
- **Databricks Resources**: Workspace, network config, storage config, credentials config

## 🎯 Outputs

After deployment, you'll get:
- `databricks_workspace_url` - Direct link to your workspace
- `unity_catalog_metastore_id` - Metastore identifier
- `vpc_id` - VPC identifier
- `s3_root_bucket` - S3 bucket name

## 🔧 Customization

The modules are designed to be reusable. You can:
- Change the `prefix` to deploy multiple environments
- Modify VPC CIDR blocks for different network ranges
- Adjust security group rules as needed
- Use different Unity Catalog metastores

## 📚 Documentation

- [Databricks Terraform Provider](https://registry.terraform.io/providers/databricks/databricks/latest/docs)
- [AWS Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Unity Catalog Documentation](https://docs.databricks.com/data-governance/unity-catalog/index.html)
