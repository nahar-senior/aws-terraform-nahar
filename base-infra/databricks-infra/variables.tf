variable "databricks_account_id" {
  description = "Databricks Account ID"
  type        = string
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "security_group_ids" {
  description = "IDs of the security groups"
  type        = list(string)
}

variable "root_bucket_name" {
  description = "Name of the root S3 bucket"
  type        = string
}

variable "cross_account_role_arn" {
  description = "ARN of the cross-account IAM role"
  type        = string
}

variable "credentials_id" {
  description = "ID of the Databricks credentials"
  type        = string
}

variable "storage_configuration_id" {
  description = "ID of the Databricks storage configuration"
  type        = string
}

variable "network_id" {
  description = "ID of the Databricks network configuration"
  type        = string
}
