# =============================================================================
# DATABRICKS WORKSPACE MODULE
# =============================================================================
# Creates and configures a Databricks workspace with Unity Catalog integration
# This module handles:
# - Workspace creation with ENTERPRISE tier
# - Network, storage, and credentials configuration
# - Unity Catalog metastore creation or attachment
# - Cross-account role integration

# =============================================================================
# DATABRICKS WORKSPACE CREATION
# =============================================================================
# The main workspace resource that brings together all configurations
# Create the Databricks workspace with all required configurations
# This is the main resource that users will interact with
resource "databricks_mws_workspaces" "this" {
  provider       = databricks.mws                          # Account-level operations
  account_id     = var.databricks_account_id               # Your Databricks account
  workspace_name = var.workspace_name                      # Human-readable workspace name
  
  # AWS Region Configuration
  aws_region = var.aws_region                             # Region for workspace deployment
  
  # Network Configuration - Links to AWS VPC
  network_id = databricks_mws_networks.this.network_id    # VPC integration for clusters
  
  # Storage Configuration - Links to S3 bucket
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  
  # Credentials Configuration - Links to IAM role
  credentials_id = databricks_mws_credentials.this.credentials_id  # Cross-account access
  
  # Pricing and Features
  pricing_tier = var.pricing_tier                          # ENTERPRISE enables Unity Catalog
  
  # Ensure all MWS configurations are created before workspace
  depends_on = [
    databricks_mws_networks.this,                         # Network must exist first
    databricks_mws_storage_configurations.this,           # Storage must be configured
    databricks_mws_credentials.this                       # Credentials must be set up
  ]
  
  # This workspace will be accessible at: https://dbc-<workspace-id>.cloud.databricks.com
}

# =============================================================================
# UNITY CATALOG CONFIGURATION (DATA GOVERNANCE)
# =============================================================================
# Unity Catalog provides centralized data governance across Databricks workspaces

# Create Unity Catalog Metastore (optional - based on create_metastore flag)
resource "databricks_metastore" "this" {
  count = var.create_metastore ? 1 : 0                    # Only create if requested
  
  provider      = databricks.mws
  name          = var.metastore_name != null ? var.metastore_name : "${var.workspace_name}-metastore"
  storage_root  = "s3://${var.unity_catalog_bucket_name != null ? var.unity_catalog_bucket_name : var.root_bucket_name}/unity-catalog"
  region        = var.aws_region                          # Must match workspace region
  
  depends_on = [databricks_mws_workspaces.this]
  
  # Unity Catalog Metastore provides:
  # - Centralized data governance across workspaces
  # - Fine-grained access controls (RBAC)
  # - Data lineage and discovery
  # - Cross-workspace data sharing
  # - Delta Sharing capabilities
}

# Assign Unity Catalog Metastore to the workspace
# This enables data governance features in the workspace
resource "databricks_metastore_assignment" "this" {
  provider      = databricks.mws
  metastore_id  = var.create_metastore ? databricks_metastore.this[0].id : var.existing_metastore_id
  workspace_id  = databricks_mws_workspaces.this.workspace_id
  
  depends_on = [
    databricks_mws_workspaces.this,                       # Workspace must exist
    databricks_metastore.this                             # Metastore must be ready (if creating)
  ]
  
  # After assignment, the workspace will have:
  # - Access to Unity Catalog features
  # - Ability to create catalogs, schemas, and tables
  # - Data governance and access control capabilities
  # - Integration with the broader data platform
}

# =============================================================================
# DATABRICKS MWS (MANAGED WORKSPACE SERVICE) CONFIGURATIONS
# =============================================================================
# These resources link AWS infrastructure to Databricks account

# Network Configuration - Links Databricks to your VPC
resource "databricks_mws_networks" "this" {
  provider         = databricks.mws
  account_id       = var.databricks_account_id            # Your Databricks account
  network_name     = "${var.workspace_name}-network"      # Descriptive name
  vpc_id          = var.vpc_id                           # VPC from base infrastructure
  subnet_ids      = var.private_subnet_ids               # Private subnets for clusters
  security_group_ids = var.security_group_ids            # Security groups for network rules
  
  # This configuration tells Databricks:
  # - Which VPC to deploy clusters in
  # - Which subnets to use for cluster nodes
  # - Which security groups control network access
  # - How to route traffic between clusters and control plane
}

# Storage Configuration - Links Databricks to your S3 bucket
resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.mws
  account_id                = var.databricks_account_id  # Your Databricks account
  storage_configuration_name = "${var.workspace_name}-storage"  # Descriptive name
  bucket_name               = var.root_bucket_name       # S3 bucket from base infrastructure
  
  # This configuration tells Databricks:
  # - Where to store DBFS (Databricks File System) data
  # - Where to write cluster logs and temporary files
  # - Where to store workspace-specific data
  # - Root location for all workspace storage needs
}

# Credentials Configuration - Links Databricks to your IAM role
resource "databricks_mws_credentials" "this" {
  provider         = databricks.mws
  account_id       = var.databricks_account_id            # Your Databricks account
  credentials_name = "${var.workspace_name}-credentials"  # Descriptive name
  role_arn        = var.cross_account_role_arn           # IAM role from base infrastructure
  
  # This configuration tells Databricks:
  # - Which IAM role to assume for AWS operations
  # - How to access your AWS resources securely
  # - What permissions are available for cluster operations
  # - How to maintain secure cross-account access
  
  # The cross-account role enables Databricks to:
  # - Launch EC2 instances for clusters
  # - Access S3 for data operations
  # - Manage AWS networking components
  # - Perform other required AWS API calls
}
