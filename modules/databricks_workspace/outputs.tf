# =============================================================================
# DATABRICKS WORKSPACE MODULE OUTPUTS
# =============================================================================
# These outputs provide essential information about the created workspace
# and its associated configurations for integration and management

# =============================================================================
# WORKSPACE INFORMATION
# =============================================================================

output "workspace_id" {
  description = "Databricks workspace ID - unique identifier for API calls and automation"
  value       = databricks_mws_workspaces.this.workspace_id
  
  # Use for:
  # - Databricks REST API calls
  # - Terraform state references
  # - Integration with other Databricks resources
  # - Workspace-specific configurations
}

output "workspace_url" {
  description = "Databricks workspace URL - direct link to access the workspace"
  value       = databricks_mws_workspaces.this.workspace_url
  
  # This is the URL users will use to access Databricks
  # Format: https://dbc-xxxxxxxx-xxxx.cloud.databricks.com
  # Bookmark this for daily usage by data teams
}

output "workspace_status" {
  description = "Databricks workspace status - indicates deployment and operational state"
  value       = databricks_mws_workspaces.this.workspace_status
  
  # Status values:
  # - RUNNING: Workspace is ready for use
  # - PROVISIONING: Still being created
  # - FAILED: Deployment encountered errors
  # - BANNED: Workspace has been disabled
}

output "workspace_name" {
  description = "Name of the Databricks workspace - human-readable identifier"
  value       = var.workspace_name
  
  # Matches the workspace name shown in Databricks UI
  # Useful for documentation and identification
}

# =============================================================================
# MWS CONFIGURATION IDENTIFIERS
# =============================================================================
# These IDs reference the managed workspace service configurations

output "network_id" {
  description = "Databricks network configuration ID - links workspace to VPC"
  value       = databricks_mws_networks.this.network_id
  
  # References the VPC, subnets, and security groups
  # Used internally by Databricks for cluster networking
}

output "storage_configuration_id" {
  description = "Databricks storage configuration ID - links workspace to S3 bucket"
  value       = databricks_mws_storage_configurations.this.storage_configuration_id
  
  # References the S3 bucket for DBFS and workspace data
  # Used internally by Databricks for data storage operations
}

output "credentials_id" {
  description = "Databricks credentials configuration ID - links workspace to IAM role"
  value       = databricks_mws_credentials.this.credentials_id
  
  # References the cross-account IAM role
  # Used internally by Databricks for AWS API operations
}

# =============================================================================
# UNITY CATALOG INFORMATION (DATA GOVERNANCE)
# =============================================================================
# Information about Unity Catalog configuration for data governance

output "metastore_id" {
  description = "Unity Catalog metastore ID - identifier for data governance operations"
  value       = var.create_metastore ? databricks_metastore.this[0].id : var.existing_metastore_id
  
  # This metastore provides:
  # - Centralized data governance
  # - Cross-workspace data sharing
  # - Fine-grained access controls
  # - Data lineage tracking
  # - Delta Sharing capabilities
}

output "metastore_name" {
  description = "Unity Catalog metastore name - human-readable identifier"
  value       = var.create_metastore ? databricks_metastore.this[0].name : null
  
  # Displays in Databricks UI for data catalog operations
  # null if using existing metastore (name comes from existing metastore)
  # Used in Data tab for catalog, schema, and table management
}
