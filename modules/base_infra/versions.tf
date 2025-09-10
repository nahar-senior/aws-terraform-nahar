# =============================================================================
# BASE INFRASTRUCTURE MODULE - PROVIDER REQUIREMENTS
# =============================================================================
# Defines the required providers and versions for this module
# Ensures compatibility and access to required features

terraform {
  required_providers {
    # AWS Provider: Creates and manages AWS infrastructure resources
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.57.0"                    # Minimum version for VPC endpoint features
    }

    # Databricks Provider: Fetches account-specific policies and configurations
    databricks = {
      source                = "databricks/databricks"
      version               = ">=1.49.0"                    # Version with Unity Catalog improvements
      configuration_aliases = [databricks.mws]             # Account-level provider alias
    }
  }
  
  # Version Rationale:
  # - AWS 4.57.0+: Required for latest VPC endpoint configurations
  # - Databricks 1.49.0+: Improved Unity Catalog and MWS resource support
  # - configuration_aliases: Allows passing provider from parent module
}