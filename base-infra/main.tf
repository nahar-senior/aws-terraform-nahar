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
  }
}

provider "aws" {
  region = var.region
}

provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}

locals {
  prefix = "naharsenior"
}

module "aws_infra" {
  source = "./aws-infra"

  providers = {
    databricks.mws = databricks.mws
  }

  databricks_account_id = var.databricks_account_id
  cidr_block           = var.cidr_block
  region               = var.region
  prefix               = local.prefix
  tags                 = var.tags
}

module "databricks_infra" {
  source = "./databricks-infra"

  providers = {
    databricks.mws = databricks.mws
  }

  databricks_account_id    = var.databricks_account_id
  region                   = var.region
  prefix                   = local.prefix
  vpc_id                  = module.aws_infra.vpc_id
  subnet_ids              = module.aws_infra.subnet_ids
  security_group_ids      = [module.aws_infra.security_group_id]
  root_bucket_name        = module.aws_infra.root_bucket_name
  cross_account_role_arn  = module.aws_infra.cross_account_role_arn
  credentials_id          = module.aws_infra.credentials_id
  storage_configuration_id = module.aws_infra.storage_configuration_id
  network_id              = module.aws_infra.network_id

  depends_on = [module.aws_infra]
}
