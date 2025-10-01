output "cluster_id" {
  description = "ID of the created cluster"
  value       = databricks_cluster.interactive.id
}

output "cluster_name" {
  description = "Name of the created cluster"
  value       = databricks_cluster.interactive.cluster_name
}

output "cluster_url" {
  description = "URL to access the cluster"
  value       = databricks_cluster.interactive.url
}
