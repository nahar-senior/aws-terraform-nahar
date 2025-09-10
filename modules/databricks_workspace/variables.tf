# =============================================================================
# DATABRICKS WORKSPACE MODULE VARIABLES
# =============================================================================
# Input variables for the Databricks workspace module
# These control workspace creation and Unity Catalog configuration

# =============================================================================
# DATABRICKS ACCOUNT CONFIGURATION
# =============================================================================

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID for workspace creation"
  
  # Format: UUID like "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  # Used for all account-level operations and MWS resource creation
}

variable "workspace_name" {
  type        = string
  description = "Name of the Databricks workspace - appears in Databricks UI"
  
  # Used for:
  # - Workspace identification in Databricks console
  # - MWS resource naming (network, storage, credentials)
  # - Default metastore naming (if creating new metastore)
}

# =============================================================================
# AWS INFRASTRUCTURE INTEGRATION
# =============================================================================
# These variables link the workspace to AWS infrastructure components

variable "aws_region" {
  type        = string
  description = "AWS region where the workspace will be deployed"
  
  # Must match:
  # - Region of the VPC and subnets
  # - Region of the S3 bucket
  # - Region where Databricks is available
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Databricks clusters will be deployed"
  
  # From base infrastructure module output
  # Provides network isolation and security for clusters
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for Databricks clusters"
  
  # From base infrastructure module output
  # Clusters will be deployed in these subnets for security
  # Must have internet access via NAT Gateway for package downloads
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs for Databricks network access"
  
  # From base infrastructure module output
  # Controls inbound/outbound traffic for clusters
  # Includes rules for SSH, HTTPS, and Databricks communication
}

variable "root_bucket_name" {
  type        = string
  description = "S3 bucket name for Databricks root storage"
  
  # From base infrastructure module output
  # Used for DBFS, cluster logs, and workspace data
  # Must be accessible by the cross-account role
}

variable "cross_account_role_arn" {
  type        = string
  description = "ARN of the cross-account IAM role for Databricks AWS access"
  
  # From base infrastructure module output
  # Enables Databricks to manage AWS resources on your behalf
  # Has permissions for EC2, S3, networking, and other required services
}

# =============================================================================
# DATABRICKS WORKSPACE CONFIGURATION
# =============================================================================

variable "pricing_tier" {
  type        = string
  description = "Databricks pricing tier - determines available features"
  default     = "ENTERPRISE"
  
  # Tier Capabilities:
  # - STANDARD: Basic Databricks features, collaborative notebooks
  # - PREMIUM: Advanced security, RBAC, audit logs, job scheduling
  # - ENTERPRISE: Unity Catalog, advanced governance, SSO, private connectivity
  
  validation {
    condition     = contains(["STANDARD", "PREMIUM", "ENTERPRISE"], var.pricing_tier)
    error_message = "Pricing tier must be either STANDARD, PREMIUM, or ENTERPRISE."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to Databricks resources"
  default     = {}
  
  # Applied to MWS resources for governance and cost tracking
  # Recommended: Environment, Project, Owner, CostCenter
}

# =============================================================================
# UNITY CATALOG CONFIGURATION (DATA GOVERNANCE)
# =============================================================================

variable "create_metastore" {
  type        = bool
  description = "Whether to create a new Unity Catalog metastore"
  default     = true
  
  # Set to true: Creates new metastore for this workspace
  # Set to false: Attach to existing metastore (use existing_metastore_id)
  # Note: Each account has limits on metastores per region
}

variable "metastore_name" {
  type        = string
  description = "Name of the Unity Catalog metastore (only used if creating new)"
  default     = null
  
  # Only required when create_metastore = true
  # If null, defaults to "${workspace_name}-metastore"
  # Appears in Databricks Data tab for catalog operations
}

variable "existing_metastore_id" {
  type        = string
  description = "ID of existing metastore to attach (only used if not creating new)"
  default     = null
  
  # Required when create_metastore = false
  # Format: UUID like "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  # Find in Databricks UI: Data > Catalog > Settings > Metastore
}

variable "unity_catalog_bucket_name" {
  type        = string
  description = "S3 bucket name for Unity Catalog metastore storage (optional)"
  default     = null
  
  # If null, uses root_bucket_name for Unity Catalog data
  # If specified, Unity Catalog data will be stored in this separate bucket
  # Path will be: s3://bucket-name/unity-catalog/
}
