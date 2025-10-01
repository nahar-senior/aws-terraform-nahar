output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "security_group_id" {
  description = "ID of the default security group"
  value       = module.vpc.default_security_group_id
}

output "root_bucket_name" {
  description = "Name of the root S3 bucket"
  value       = aws_s3_bucket.root_storage_bucket.bucket
}

output "cross_account_role_arn" {
  description = "ARN of the cross-account IAM role"
  value       = aws_iam_role.cross_account_role.arn
}

output "credentials_id" {
  description = "ID of the Databricks credentials"
  value       = databricks_mws_credentials.this.credentials_id
}

output "storage_configuration_id" {
  description = "ID of the Databricks storage configuration"
  value       = databricks_mws_storage_configurations.this.storage_configuration_id
}

output "network_id" {
  description = "ID of the Databricks network configuration"
  value       = databricks_mws_networks.this.network_id
}
