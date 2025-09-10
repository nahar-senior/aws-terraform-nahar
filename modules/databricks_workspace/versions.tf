# =============================================================================
# DATABRICKS WORKSPACE MODULE - PROVIDER REQUIREMENTS
# =============================================================================
# Defines the required providers and versions for the workspace module
# Ensures compatibility and access to required Databricks features

terraform {
  required_providers {
    # Databricks Provider: Creates and manages Databricks workspace resources
    databricks = {
      source                = "databricks/databricks"
      version               = ">=1.49.0"                    # Version with Unity Catalog improvements
      configuration_aliases = [databricks.mws]             # Account-level provider alias
    }
  }
  
  # Version Rationale:
  # - Databricks 1.49.0+: Improved Unity Catalog and MWS resource support
  # - configuration_aliases: Allows using the account-level provider from parent module
  # - This module focuses only on Databricks resources (no AWS resources directly)
}
