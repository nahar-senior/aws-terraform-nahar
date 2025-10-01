# Create Databricks workspace
resource "databricks_mws_workspaces" "this" {
  provider       = databricks.mws
  account_id     = var.databricks_account_id
  aws_region     = var.region
  workspace_name = var.prefix

  credentials_id           = var.credentials_id
  storage_configuration_id = var.storage_configuration_id
  network_id               = var.network_id
}

# Create a new metastore for this workspace
resource "databricks_metastore" "this" {
  provider = databricks.mws
  
  name          = "${var.prefix}-metastore"
  storage_root  = "s3://${var.root_bucket_name}/metastore"
  region        = var.region
  force_destroy = true
}

# Attach metastore to workspace
resource "databricks_metastore_assignment" "this" {
  provider = databricks.mws
  
  metastore_id = databricks_metastore.this.id
  workspace_id = databricks_mws_workspaces.this.workspace_id
}
