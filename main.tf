# =============================================================================
# TERRAFORM CONFIGURATION
# =============================================================================
# Define minimum Terraform version and required provider versions
# This ensures consistency across team members and environments

terraform {
  required_version = ">= 1.0"  # Minimum Terraform version for stability
  
  required_providers {
    # AWS Provider: Manages AWS infrastructure resources
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.57.0"  # Version that supports latest VPC endpoint features
    }
    
    # Databricks Provider: Manages Databricks workspace and Unity Catalog resources
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.49.0"  # Latest version with Unity Catalog improvements
    }
  }
}

# =============================================================================
# PROVIDER CONFIGURATIONS
# =============================================================================

# AWS Provider Configuration
# Manages all AWS resources (VPC, S3, IAM, etc.)
provider "aws" {
  region = var.aws_region  # Deploy to specified AWS region
  
  # Apply default tags to ALL AWS resources automatically
  # This ensures consistent tagging across infrastructure for cost tracking and governance
  default_tags {
    tags = var.default_tags
  }
}

# Databricks Provider Configuration for Account-Level Operations
# This provider handles workspace creation, Unity Catalog, and cross-account setup
# Uses OAuth authentication via Databricks CLI (more secure than PAT tokens)
provider "databricks" {
  alias      = "mws"                         # Alias for account-level operations
  host       = var.databricks_host           # Databricks account console URL
  account_id = var.databricks_account_id     # Your Databricks account identifier
  # OAuth authentication automatically uses cached token from 'databricks auth login'
  # This eliminates the need for hardcoded Personal Access Tokens
}

# =============================================================================
# BASE INFRASTRUCTURE MODULE
# =============================================================================
# Creates the foundational AWS infrastructure required for Databricks:
# - VPC with public/private subnets across multiple AZs
# - Security groups with Databricks-optimized rules
# - S3 bucket for Databricks root storage (encrypted)
# - IAM cross-account role for Databricks to manage AWS resources
# - VPC endpoints for cost optimization and security
# - NAT Gateway for private subnet internet access

module "databricks_base_infra" {
  source = "./modules/base_infra"
  
  # Pass the Databricks provider for fetching account-specific policies
  providers = {
    databricks.mws = databricks.mws
  }
  
  # Infrastructure Configuration
  prefix                    = var.prefix                    # Naming prefix for all resources
  cidr_block               = var.vpc_cidr_block             # VPC network range
  region                   = var.aws_region                # AWS region for deployment
  databricks_account_id    = var.databricks_account_id     # For cross-account trust policies
  databricks_workspace_name = var.databricks_workspace_name # Used in resource naming
  roles_to_assume          = var.roles_to_assume           # Additional IAM roles for clusters
  tags                     = var.default_tags              # Resource tags for governance
}

# =============================================================================
# DATABRICKS WORKSPACE MODULE
# =============================================================================
# Creates the Databricks workspace and integrates it with the AWS infrastructure:
# - Databricks workspace with ENTERPRISE tier (Unity Catalog support)
# - Network configuration linking VPC to Databricks
# - Storage configuration linking S3 bucket to Databricks
# - Credentials configuration linking IAM role to Databricks
# - Unity Catalog metastore assignment for data governance

module "databricks_workspace" {
  source = "./modules/databricks_workspace"
  
  # Use the same Databricks provider for account-level operations
  providers = {
    databricks.mws = databricks.mws
  }
  
  # Databricks Account Configuration
  databricks_account_id    = var.databricks_account_id
  workspace_name           = var.databricks_workspace_name
  aws_region              = var.aws_region
  pricing_tier            = var.databricks_pricing_tier     # ENTERPRISE for Unity Catalog
  
  # AWS Infrastructure Integration (from base_infra module outputs)
  vpc_id                  = module.databricks_base_infra.vpc_id                    # VPC for network isolation
  private_subnet_ids      = module.databricks_base_infra.subnets                  # Private subnets for clusters
  security_group_ids      = module.databricks_base_infra.security_group_ids       # Security rules for Databricks
  root_bucket_name        = module.databricks_base_infra.root_bucket              # S3 for workspace storage
  cross_account_role_arn  = module.databricks_base_infra.cross_account_role_arn   # IAM for AWS resource access
  
  # Unity Catalog Configuration (Data Governance)
  create_metastore         = var.create_unity_catalog_metastore  # false = use existing metastore
  metastore_name          = var.unity_catalog_metastore_name     # Name for new metastore (if creating)
  existing_metastore_id   = var.existing_metastore_id           # ID of existing metastore to attach
  unity_catalog_bucket_name = module.databricks_base_infra.root_bucket  # S3 location for Unity Catalog data
  
  # Resource Management
  tags = var.default_tags
  
  # Ensure base infrastructure is created before workspace
  depends_on = [module.databricks_base_infra]
}
