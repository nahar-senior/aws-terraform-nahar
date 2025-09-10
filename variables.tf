# =============================================================================
# INFRASTRUCTURE CONFIGURATION VARIABLES
# =============================================================================
# These variables control the core infrastructure settings

variable "prefix" {
  type        = string
  description = "Prefix for naming all resources - ensures unique and identifiable resource names"
  default     = "nahar-tf"
  
  # Used for: VPC names, S3 buckets, IAM roles, security groups, etc.
  # Example: prefix "my-company" creates resources like "my-company-vpc", "my-company-rootbucket"
}

variable "aws_region" {
  type        = string
  description = "AWS region for deployment - affects availability zones and service availability"
  default     = "us-west-2"
  
  # Considerations:
  # - Choose region close to your users for lower latency
  # - Verify Databricks is available in your chosen region
  # - Consider data residency requirements
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC - defines the IP address range for your network"
  default     = "10.0.0.0/16"
  
  # Network Design:
  # - /16 provides 65,536 IP addresses (65,534 usable)
  # - Automatically split into subnets: public /19, private /19 + /19
  # - Ensure no conflicts with existing networks if using VPC peering
}

# =============================================================================
# DATABRICKS ACCOUNT CONFIGURATION
# =============================================================================
# These variables connect to your Databricks account

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID - unique identifier for your Databricks account"
  # No default - must be provided (format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
  
  # How to find:
  # 1. Go to https://accounts.cloud.databricks.com
  # 2. Click on your account name (top right)
  # 3. Copy the Account ID from the dropdown
}

variable "databricks_host" {
  type        = string
  description = "Databricks Host URL - the account console endpoint"
  default     = "https://accounts.cloud.databricks.com"
  
  # Standard URL for Databricks account operations
  # Only change if using a different Databricks cloud or government instance
}

# =============================================================================
# AUTHENTICATION CONFIGURATION
# =============================================================================
# OAuth authentication is used instead of Personal Access Tokens
# This is more secure and eliminates hardcoded credentials
# Run: databricks auth login --host https://accounts.cloud.databricks.com --account-id YOUR_ACCOUNT_ID

variable "databricks_workspace_name" {
  type        = string
  description = "Name of the Databricks workspace - appears in Databricks UI"
  default     = "nahar-tf-workspace"
  
  # Naming convention: Use prefix for consistency with other resources
  # Example: "my-company-prod", "my-company-dev", etc.
}

# =============================================================================
# IAM AND SECURITY CONFIGURATION
# =============================================================================

variable "roles_to_assume" {
  type        = list(string)
  description = "List of IAM role ARNs that can be assumed by the cross-account role"
  default     = []
  
  # Use case: Instance profiles for Databricks clusters
  # Example: ["arn:aws:iam::123456789012:role/databricks-s3-access-role"]
  # These roles can be attached to clusters for accessing AWS services like S3, RDS, etc.
  # Leave empty if you don't need custom instance profiles
}

# =============================================================================
# DATABRICKS WORKSPACE CONFIGURATION
# =============================================================================

variable "databricks_pricing_tier" {
  type        = string
  description = "Databricks workspace pricing tier - determines available features"
  default     = "ENTERPRISE"
  
  # Tier Comparison:
  # - STANDARD: Basic Databricks features
  # - PREMIUM: Advanced security, RBAC, audit logs
  # - ENTERPRISE: Unity Catalog, advanced governance, SSO
  
  validation {
    condition     = contains(["STANDARD", "PREMIUM", "ENTERPRISE"], var.databricks_pricing_tier)
    error_message = "Pricing tier must be either STANDARD, PREMIUM, or ENTERPRISE."
  }
}

# =============================================================================
# UNITY CATALOG CONFIGURATION (DATA GOVERNANCE)
# =============================================================================
# Unity Catalog provides centralized data governance across workspaces

variable "create_unity_catalog_metastore" {
  type        = bool
  description = "Whether to create a Unity Catalog metastore with the workspace"
  default     = true
  
  # Set to true: Creates new metastore for this workspace
  # Set to false: Attach workspace to existing metastore (cross-workspace data sharing)
  # Note: Each account has limits on metastores per region
}

variable "unity_catalog_metastore_name" {
  type        = string
  description = "Name for the Unity Catalog metastore (only used if creating new)"
  default     = null
  
  # Only required when create_unity_catalog_metastore = true
  # Recommendation: Use same prefix as other resources for consistency
}

variable "existing_metastore_id" {
  type        = string
  description = "ID of existing metastore to attach (only used if not creating new)"
  default     = null
  
  # Required when create_unity_catalog_metastore = false
  # Format: UUID like "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  # Find in Databricks UI: Data > Catalog > Settings > Metastore
}

# =============================================================================
# RESOURCE MANAGEMENT AND GOVERNANCE
# =============================================================================

variable "default_tags" {
  type        = map(string)
  description = "Default tags applied to all AWS resources for governance and cost tracking"
  default = {
    Project     = "Databricks Infrastructure"
    ManagedBy   = "Terraform"
    Environment = "production"
  }
  
  # Best Practices for Tags:
  # - Project: For cost allocation and resource grouping
  # - ManagedBy: Identifies infrastructure-as-code vs manual resources
  # - Environment: Separates prod/dev/staging costs and policies
  # - Owner: Contact person for the resources
  # - CostCenter: For chargeback and budgeting
  
  # These tags are automatically applied to ALL AWS resources via the aws provider
  # Additional tags can be added per module for specific resource types
}
