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
  igw_name = "igwue1ingamesbx001"
  rtb_public_name = "rtb-public"
  rtb_private1_name = "rtb-private1"
  rtb_private2_name = "rtb-private2"
  az_a_name = "us-east-1a"
  az_b_name = "us-east-1b"
  cognito_name = "upnaeu1ingamesbx001"
  rds_name = "rdspue1ingamesbx001"
  ec2_pivot_name = "ec2lue1ingamesbx001"
  separator_symbol = "-"
  pl_destination_id = "pl-63a5400a"
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

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = local.igw_name
    Environment = local.environment
  }
}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = "172.31.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = join(local.separator_symbol, [local.vpc_name,local.rtb_public_name])
    Environment = local.environment
  }
}

resource "aws_route_table_association" "rtb_public_1a" {
  subnet_id      = aws_subnet.subnet_public1.id
  route_table_id = aws_route_table.route_table_public.id
  depends_on = [ aws_route_table.route_table_public ]
}

resource "aws_route_table_association" "rtb_public_1b" {
  subnet_id      = aws_subnet.subnet_public2.id
  route_table_id = aws_route_table.route_table_public.id
  depends_on = [ aws_route_table.route_table_public ]
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.us-east-1.s3"

  tags = {
    Environment = local.environment
  }
}

resource "aws_route_table" "route_table_private1" {
  vpc_id = aws_vpc.vpc.id

  route {
    destination_prefix_list_id = local.pl_destination_id
    vpc_endpoint_id = aws_vpc_endpoint.s3.id
  }

  route {
    cidr_block = "172.31.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = join(local.separator_symbol, [local.vpc_name,local.rtb_private1_name,local.az_a_name])
    Environment = local.environment
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_private1.id
  route_table_id = aws_route_table.route_table_private1.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "vpc_arn" {
  value = aws_vpc.vpc.arn
}