# =============================================================================
# BASE INFRASTRUCTURE MODULE - IAM AND CROSS-ACCOUNT SETUP
# =============================================================================
# This module creates the foundational AWS infrastructure required for Databricks
# Focus: IAM roles, policies, and cross-account trust relationships

# Merge default tags with additional metadata tags
# These tags will be applied to all resources in this module
locals {
  common_tags = merge(var.tags, {
    Environment         = var.prefix                    # Environment identifier
    ManagedBy          = "Terraform"                    # Infrastructure-as-code indicator
    DatabricksWorkspace = var.databricks_workspace_name # Associate with specific workspace
  })
}

# =============================================================================
# DATABRICKS DATA SOURCES - ACCOUNT-SPECIFIC POLICIES
# =============================================================================
# These data sources fetch Databricks-managed policies for your specific account
# They ensure proper cross-account trust and permissions

# Fetch the assume role policy for cross-account access
# This policy allows Databricks' AWS account to assume roles in your account
data "databricks_aws_assume_role_policy" "this" {
  provider    = databricks.mws              # Use account-level Databricks provider
  external_id = var.databricks_account_id   # Your unique Databricks account ID
  
  # This generates a trust policy that:
  # - Allows Databricks AWS account (414351767826) to assume the role
  # - Requires external_id for additional security
  # - Prevents confused deputy attacks
}

# Create the cross-account IAM role for Databricks
# This is the primary role that Databricks will assume to manage AWS resources
resource "aws_iam_role" "cross_account_role" {
  name               = "${var.prefix}-crossaccount"          # Consistent naming with prefix
  assume_role_policy = data.databricks_aws_assume_role_policy.this.json  # Trust policy from Databricks
  tags               = local.common_tags
  
  # This role enables Databricks to:
  # - Launch and manage EC2 instances for clusters
  # - Access S3 buckets for data storage
  # - Manage networking components (security groups, etc.)
  # - Perform other AWS operations required for workspace functionality
}

# Fetch the cross-account policy with all required permissions
# This policy defines what actions Databricks can perform in your AWS account
data "databricks_aws_crossaccount_policy" "this" {
  provider = databricks.mws
  
  # This policy includes permissions for:
  # - EC2: Instance management, networking, storage
  # - IAM: Service-linked role creation, role management
  # - VPC: Network interface management
  # - EBS: Volume management for cluster storage
}

# Combine Databricks policy with optional custom role passing permissions
# This creates a comprehensive policy document for the cross-account role
data "aws_iam_policy_document" "this" {
  # Start with the base Databricks cross-account policy
  source_policy_documents = [data.databricks_aws_crossaccount_policy.this.json]

  # Conditionally add PassRole permissions for custom instance profiles
  # Only included if you have specified additional roles for cluster access
  dynamic "statement" {
    for_each = length(var.roles_to_assume) > 0 ? [1] : []
    content {
      sid       = "allowPassCrossServiceRole"
      effect    = "Allow"
      actions   = ["iam:PassRole"]                    # Allow passing roles to EC2 instances
      resources = var.roles_to_assume                 # Specific roles that can be passed
      
      # Use case: Custom instance profiles for accessing S3, RDS, or other AWS services
      # Example: Data science teams need different S3 access patterns per project
    }
  }
}

# Attach the comprehensive policy to the cross-account role
# This gives Databricks all necessary permissions to operate in your AWS account
resource "aws_iam_role_policy" "this" {
  name   = "${var.prefix}-policy"                    # Consistent naming
  role   = aws_iam_role.cross_account_role.id        # Attach to the cross-account role
  policy = data.aws_iam_policy_document.this.json    # The combined policy document
  
  # This policy attachment completes the IAM setup required for Databricks
  # Without this, Databricks cannot create clusters or manage AWS resources
}
