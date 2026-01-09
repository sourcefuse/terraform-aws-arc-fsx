################################################################
## defaults
################################################################
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
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
  }
}

module "security_group" {
  source = "sourcefuse/arc-security-group/aws"

  name   = "${var.namespace}-${var.environment}-fsx-windows-self-managed-sg"
  vpc_id = data.aws_vpc.ascend.id

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

  tags = module.tags.tags
}

module "fsx_windows_self_managed" {
  source = "../.."

  name        = "windows-self-managed-ad"
  environment = "prod"
  fsx_type    = "windows"

  # Network Configuration
  vpc_id             = data.aws_vpc.ascend.id
  subnet_ids         = data.aws_subnets.private.ids
  security_group_ids = [module.security_group.id]

  # FSx Configuration
  storage_capacity    = 32
  throughput_capacity = 32
  deployment_type     = "SINGLE_AZ_2"
  storage_type        = "SSD"

  # Windows Configuration
  windows_configuration = {
    self_managed_active_directory = {
      dns_ips     = var.ad_dns_ips
      domain_name = var.ad_domain_name
      # password                               = var.ad_password
      # username                               = var.ad_username
      username                               = local.ad_credentials.username
      password                               = local.ad_credentials.password
      file_system_administrators_group       = var.ad_admin_group
      organizational_unit_distinguished_name = var.ad_ou_dn
    }
    audit_log_configuration = {
      file_access_audit_log_level       = "SUCCESS_AND_FAILURE"
      file_share_access_audit_log_level = "SUCCESS_AND_FAILURE"
    }
  }

  # Backup Configuration
  # backup_configuration = {
  #   automatic_backup_retention_days   = 7
  #   daily_automatic_backup_start_time = "02:00"
  # }

  weekly_maintenance_start_time = "1:03:00"

  tags = module.tags.tags
}
