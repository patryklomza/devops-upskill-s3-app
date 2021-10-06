locals {
  owner        = "plomza"
  region       = "eu-central-1"
  azs          = ["${local.region}a", "${local.region}b"]
  public_cidr  = ["10.0.1.0/25", "10.0.1.128/25"]
  s3_app_cidr  = ["10.0.2.0/25", "10.0.2.128/25"]
  rds_app_cidr = ["10.0.3.0/25", "10.0.3.128/25"]
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}
provider "aws" {
  region  = "eu-central-1"
  profile = "plomza"
  default_tags {
    tags = {
      Owner = local.owner
    }
  }
}

module "network" {
  source        = "./modules/network"
  cidr_block    = "10.0.0.0/16"
  region        = local.region
  owner_tag     = local.owner
  public_subnet = zipmap(local.azs, local.public_cidr)
  s3_subnet     = zipmap(local.azs, local.s3_app_cidr)
  rds_subnet    = zipmap(local.azs, local.rds_app_cidr)
  azs           = local.azs
}
