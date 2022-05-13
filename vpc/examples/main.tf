# Basic example

terraform {
  required_version = "1.1.9"
  required_providers {
    aws = {
      version = "4.13.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_region" "current" {}

locals {
  availability_zones = [join("", [data.aws_region.current.name, "a"]), join("", [data.aws_region.current.name, "b"])]
}

module "vpc" {
  source         = "../"
  vpc_cidr_block = "10.0.0.0/16"
  subnets = {
    public_subnets = {
      cidr_blocks        = ["10.0.0.0/24", "10.0.1.0/24"]
      availability_zones = local.availability_zones
      ipv6_cidr_blocks   = []
    },
    private_subnets = {
      cidr_blocks        = ["10.0.2.0/24", "10.0.3.0/24"]
      availability_zones = local.availability_zones
      ipv6_cidr_blocks   = []
    }
  }

  create_internet_gateway = true

  tags = {
    Env = "test"
  }
}