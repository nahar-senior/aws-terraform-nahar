terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

# Remote state reference to base-infra
data "terraform_remote_state" "base_infra" {
  backend = "local"
  config = {
    path = "../base-infra/terraform.tfstate"
  }
}

# Provider configuration using workspace URL from base-infra
provider "databricks" {
  host          = data.terraform_remote_state.base_infra.outputs.databricks_workspace_url
  client_id     = var.client_id
  client_secret = var.client_secret
}

locals {
  prefix = "naharsenior"
}

# Cluster management module
module "cluster_management" {
  source = "./cluster-management"
  
  prefix = local.prefix
  tags   = var.tags
}
