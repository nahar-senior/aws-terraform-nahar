variable "databricks_account_id" {
  description = "Databricks Account ID"
  type        = string
}

variable "client_id" {
  description = "Databricks Service Principal Client ID for account-level operations"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Databricks Service Principal Client Secret for account-level operations"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-west-2"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "Databricks Infrastructure"
    Environment = "demo"
    ManagedBy   = "Terraform"
    Owner       = "nahar"
  }
}
