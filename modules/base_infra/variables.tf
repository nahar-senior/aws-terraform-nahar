# =============================================================================
# BASE INFRASTRUCTURE MODULE VARIABLES
# =============================================================================
# Input variables for the base infrastructure module
# These control the AWS infrastructure components

variable "tags" {
  type        = map(string)
  description = "Default tags to apply to all resources in this module"
  
  # These tags will be merged with module-specific tags
  # Recommended tags: Environment, Project, Owner, CostCenter
}

variable "prefix" {
  type        = string
  description = "Prefix for naming resources - ensures consistent and unique naming"
  
  # Used for: VPC name, S3 bucket name, IAM role names, security group names
  # Important: S3 bucket names must be globally unique across all AWS accounts
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC - defines the IP address space"
  
  # Example: "10.0.0.0/16" provides 65,536 IP addresses
  # Will be automatically subdivided into public and private subnets
}

variable "region" {
  type        = string
  description = "AWS region for resource deployment"
  
  # Considerations:
  # - Must be a region where Databricks is available
  # - Affects availability zones and service features
  # - Consider data residency and latency requirements
}

variable "roles_to_assume" {
  type        = list(string)
  description = "List of IAM role ARNs that can be assumed by the cross-account role"
  
  # Use case: Custom instance profiles for cluster-specific AWS access
  # Example: ["arn:aws:iam::123456789012:role/databricks-s3-access"]
  # Leave empty if using only the default cross-account permissions
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account ID for cross-account trust policies"
  
  # Format: UUID like "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  # Used in IAM trust policies to allow Databricks to assume the cross-account role
}

variable "databricks_workspace_name" {
  type        = string
  description = "Name of the Databricks workspace for tagging and identification"
  
  # Used for:
  # - Resource tagging to associate infrastructure with workspace
  # - Documentation and cost tracking
}
