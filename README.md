# Databricks on AWS with Terraform

A modular Terraform configuration for deploying Databricks workspaces on AWS with Unity Catalog support.

## 🏗️ Architecture

This repository provides a complete infrastructure-as-code solution for Databricks on AWS, including:

- **AWS Infrastructure**: VPC, subnets, security groups, S3 bucket, IAM roles
- **Databricks Workspace**: Enterprise-tier workspace with Unity Catalog
- **Cluster Management**: Interactive cluster with proper permissions
- **Service Principal Integration**: Automated admin access setup

## 📁 Repository Structure

```
├── modules/
│   ├── base_infra/          # AWS infrastructure (VPC, S3, IAM)
│   ├── databricks_workspace/ # Databricks workspace and Unity Catalog
│   └── cluster_management/   # Databricks cluster and permissions
├── main.tf                  # Root module configuration
├── variables.tf             # Input variables
├── outputs.tf               # Output values
├── terraform.tfvars.example # Configuration template
└── README.md               # This file
```

## 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd aws-terraform-nahar
   ```

2. **Configure your variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Deploy the infrastructure**
   ```bash
   terraform plan
   terraform apply
   ```

## 🔧 Configuration

### Required Variables

- `client_id`: Databricks service principal client ID
- `client_secret`: Databricks service principal secret
- `databricks_account_id`: Your Databricks account ID

### Optional Variables

- `region`: AWS region (default: us-west-2)
- `cidr_block`: VPC CIDR block (default: 10.0.0.0/16)
- `tags`: Resource tags

## 📋 Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- Databricks service principal with account admin permissions
- Databricks CLI installed and authenticated

## 🔒 Security

- All sensitive data is excluded via `.gitignore`
- Service principal credentials are required for deployment
- IAM roles follow least-privilege principles
- Security groups are configured per Databricks requirements

## 📚 Documentation

For detailed configuration options and best practices, see the individual module documentation in the `modules/` directory.

## ⚠️ Disclaimer

This code is for educational and demonstration purposes only. For production use, please review and customize the configuration according to your organization's security and compliance requirements.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.