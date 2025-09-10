# =============================================================================
# INFRASTRUCTURE OUTPUTS
# =============================================================================
# These outputs provide essential information about the created infrastructure
# Use these values for integration with other systems or manual verification

# AWS Infrastructure Outputs (from base_infra module)
output "vpc_id" {
  description = "The ID of the VPC - use for VPC peering or security group references"
  value       = module.databricks_base_infra.vpc_id
  
  # Example usage: Reference in other Terraform configurations for network integration
}

output "private_subnets" {
  description = "List of private subnet IDs - where Databricks clusters will run"
  value       = module.databricks_base_infra.subnets
  
  # These subnets provide network isolation for Databricks clusters
  # Clusters in these subnets access internet via NAT Gateway for security
}

output "security_group_ids" {
  description = "Security group IDs for Databricks - controls network traffic"
  value       = module.databricks_base_infra.security_group_ids
  
  # Security groups define firewall rules for:
  # - SSH access (port 22)
  # - HTTPS traffic (port 443)
  # - Databricks cluster communication (ports 8443-8451)
}

output "s3_root_bucket" {
  description = "S3 bucket name for Databricks root storage - stores workspace data"
  value       = module.databricks_base_infra.root_bucket
  
  # This bucket contains:
  # - Databricks system files
  # - Cluster logs
  # - DBFS root storage
  # - Unity Catalog data (if using existing metastore)
}

output "cross_account_role_arn" {
  description = "ARN of the cross-account IAM role - allows Databricks to manage AWS resources"
  value       = module.databricks_base_infra.cross_account_role_arn
  
  # This role enables Databricks to:
  # - Launch EC2 instances for clusters
  # - Access S3 for storage
  # - Manage networking components
  # - Create/delete AWS resources as needed
}

# =============================================================================
# ACCOUNT AND REGION INFORMATION
# =============================================================================
# Basic information about the deployment context

output "aws_account_id" {
  description = "AWS Account ID - confirms which account resources were deployed to"
  value       = data.aws_caller_identity.current.account_id
  
  # Useful for:
  # - Verification in multi-account environments
  # - IAM role ARN construction
  # - Cross-account resource references
}

output "aws_region" {
  description = "AWS Region - confirms deployment region"
  value       = var.aws_region
  
  # Important for:
  # - Multi-region deployments
  # - Data residency compliance
  # - Service availability verification
}

# =============================================================================
# DATABRICKS WORKSPACE OUTPUTS
# =============================================================================
# Essential information about the created Databricks workspace

output "databricks_workspace_id" {
  description = "Databricks workspace ID - unique identifier for API calls and automation"
  value       = module.databricks_workspace.workspace_id
  
  # Use for:
  # - Databricks REST API calls
  # - Terraform state references
  # - Integration with other Databricks resources
}

output "databricks_workspace_url" {
  description = "Databricks workspace URL - direct link to access the workspace"
  value       = module.databricks_workspace.workspace_url
  
  # This is the URL users will use to access Databricks
  # Format: https://dbc-xxxxxxxx-xxxx.cloud.databricks.com
  # Bookmark this for daily usage
}

output "databricks_workspace_status" {
  description = "Databricks workspace status - indicates deployment success"
  value       = module.databricks_workspace.workspace_status
  
  # Status values:
  # - RUNNING: Workspace is ready for use
  # - PROVISIONING: Still being created
  # - FAILED: Deployment encountered errors
}

# =============================================================================
# UNITY CATALOG OUTPUTS (DATA GOVERNANCE)
# =============================================================================
# Information about Unity Catalog configuration for data governance

output "unity_catalog_metastore_id" {
  description = "Unity Catalog metastore ID - identifier for data governance operations"
  value       = module.databricks_workspace.metastore_id
  
  # This metastore provides:
  # - Centralized data governance
  # - Cross-workspace data sharing
  # - Fine-grained access controls
  # - Data lineage tracking
}

output "unity_catalog_metastore_name" {
  description = "Unity Catalog metastore name - human-readable identifier"
  value       = module.databricks_workspace.metastore_name
  
  # Displays in Databricks UI for data catalog operations
  # null if using existing metastore (name comes from existing metastore)
}

# =============================================================================
# DATA SOURCES
# =============================================================================
# Fetch information about the current AWS context

# Get current AWS account information
# This data source provides account ID, user ARN, and user ID
data "aws_caller_identity" "current" {}
