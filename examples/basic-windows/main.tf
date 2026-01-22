################################################################
## defaults
################################################################
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

provider "aws" {
  region = var.region
}

################################################################################
## Tags
################################################################################
module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    RepoName = "terraform-aws-arc-fsx"
    Name     = "${var.namespace}-${var.environment}-fsx-windows-sg"
    FSxType  = "windows"
  }
}

module "security_group" {
  source = "sourcefuse/arc-security-group/aws"

  name   = "${var.namespace}-${var.environment}-fsx-windows-sg"
  vpc_id = data.aws_vpc.this.id

  ingress_rules = [
    {
      description = "SMB/CIFS access"
      cidr_block  = join(",", var.allowed_cidr_blocks)
      from_port   = 445
      ip_protocol = "tcp"
      to_port     = 445
    },
    {
      description = "RPC endpoint mapper"
      cidr_block  = join(",", var.allowed_cidr_blocks)
      from_port   = 135
      ip_protocol = "tcp"
      to_port     = 135
    },
    {
      description = "NetBIOS"
      cidr_block  = join(",", var.allowed_cidr_blocks)
      from_port   = 137
      ip_protocol = "tcp"
      to_port     = 139
    }
  ]

  egress_rules = [
    {
      description = "All outbound traffic"
      cidr_block  = "0.0.0.0/0"
      from_port   = -1
      ip_protocol = "-1"
      to_port     = -1
    }
  ]

  tags = {
    Name        = "${var.namespace}-${var.environment}-fsx-windows-sg"
    Environment = var.environment
    FSxType     = "windows"
  }
}

module "fsx_windows" {
  source = "../.."

  name        = "example-windows-fsx"
  environment = "dev"
  fsx_type    = "windows"

  # Network Configuration
  vpc_id             = data.aws_vpc.this.id
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [module.security_group.id]

  # FSx Configuration
  storage_capacity    = 32
  throughput_capacity = 32
  deployment_type     = "SINGLE_AZ_2"
  storage_type        = "SSD"

  # Windows Configuration
  windows_configuration = {
    active_directory_id = var.active_directory_id
  }

  # Backup Configuration
  backup_configuration = {
    automatic_backup_retention_days   = 7
    daily_automatic_backup_start_time = "03:00"
  }

  weekly_maintenance_start_time = "1:04:00"

  tags = module.tags.tags
}
