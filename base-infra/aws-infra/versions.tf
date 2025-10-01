terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.49.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }
}
