output "cluster_id" {
  description = "ID of the created cluster"
  value       = module.cluster_management.cluster_id
}

output "cluster_name" {
  description = "Name of the created cluster"
  value       = module.cluster_management.cluster_name
}

output "cluster_url" {
  description = "URL to access the cluster"
  value       = module.cluster_management.cluster_url
}

output "workspace_url" {
  description = "URL of the Databricks workspace"
  value       = data.terraform_remote_state.base_infra.outputs.databricks_workspace_url
}
