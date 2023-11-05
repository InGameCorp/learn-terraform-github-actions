# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  environment = "Sandbox"
  vpc_name = "vpccue1ingamesbx001"
  subnet_public1_name = "subnet-public1"
  subnet_public2_name = "subnet-public2"
  subnet_private1_name = "subnet-private1"
  subnet_private2_name = "subnet-private2"
  az_a_name = "us-east-1a"
  az_b_name = "us-east-1b"
  cognito_name = "upnaeu1ingamesbx001"
  rds_name = "rdspue1ingamesbx001"
  ec2_pivot_name = "ec2lue1ingamesbx001"
  separator_symbol = "-"

}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "172.31.0.0/16"
  tags = {
    Name = local.vpc_name
    Environment = local.environment
  }
}

resource "aws_subnet" "subnet_public1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.31.0.0/24"
  availability_zone = local.az_a_name
  tags = {
    Name = join(local.separator_symbol, [local.vpc_name,local.subnet_public1_name,local.az_a_name])
    Environment = local.environment
  }
}

resource "aws_subnet" "subnet_public2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.31.1.0/24"
  availability_zone = local.az_b_name
  tags = {
    Name = join(local.separator_symbol, [local.vpc_name,local.subnet_public2_name,local.az_b_name])
    Environment = local.environment
  }
}

resource "aws_subnet" "subnet_private1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.31.2.0/24"
  availability_zone = local.az_a_name
  tags = {
    Name = join(local.separator_symbol, [local.vpc_name, local.subnet_private1_name, local.az_a_name]) 
    Environment = local.environment
  }
}

resource "aws_subnet" "subnet_private2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "172.31.3.0/24"
  availability_zone = local.az_b_name
  tags = {
    Name = join(local.separator_symbol, [local.vpc_name, local.subnet_private2_name, local.az_b_name])
    Environment = local.environment
  }
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "vpc_arn" {
  value = aws_vpc.vpc.arn
}