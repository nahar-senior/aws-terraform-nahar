output "workspace_id" {
  description = "ID of the Databricks workspace"
  value       = databricks_mws_workspaces.this.workspace_id
}

output "workspace_url" {
  description = "URL of the Databricks workspace"
  value       = databricks_mws_workspaces.this.workspace_url
}

output "metastore_id" {
  description = "ID of the created Unity Catalog metastore"
  value       = databricks_metastore.this.id
}

output "metastore_name" {
  description = "Name of the created Unity Catalog metastore"
  value       = databricks_metastore.this.name
}
