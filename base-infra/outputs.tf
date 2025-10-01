output "databricks_workspace_url" {
  description = "URL of the Databricks workspace"
  value       = module.databricks_infra.workspace_url
}

output "databricks_workspace_id" {
  description = "ID of the Databricks workspace"
  value       = module.databricks_infra.workspace_id
}

output "aws_region" {
  description = "AWS region used for deployment"
  value       = var.region
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.aws_infra.vpc_id
}

output "root_s3_bucket" {
  description = "Name of the root S3 bucket"
  value       = module.aws_infra.root_bucket_name
}

output "metastore_id" {
  description = "ID of the created Unity Catalog metastore"
  value       = module.databricks_infra.metastore_id
}

output "metastore_name" {
  description = "Name of the created Unity Catalog metastore"
  value       = module.databricks_infra.metastore_name
}
