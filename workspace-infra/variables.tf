variable "client_id" {
  description = "Databricks Service Principal Client ID for workspace-level operations"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Databricks Service Principal Client Secret for workspace-level operations"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "demo"
    Project     = "databricks-terraform"
    Owner       = "siddharth.nahar@databricks.com"
  }
}
