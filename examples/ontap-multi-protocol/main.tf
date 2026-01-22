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
    RepoName    = "terraform-aws-arc-fsx"
    Project     = "Multi-Protocol Storage"
    StorageType = "ONTAP"
    Protocols   = "NFS-SMB-iSCSI"
  }
}


module "security_group" {
  source = "sourcefuse/arc-security-group/aws"

  name   = "${var.namespace}-${var.environment}-fsx-ontap-sg"
  vpc_id = data.aws_vpc.this.id

  ingress_rules = [
    {
      description = "NFS access"
      cidr_block  = data.aws_vpc.this.cidr_block
      from_port   = 2049
      ip_protocol = "tcp"
      to_port     = 2049
    },
    {
      description = "SMB/CIFS access"
      cidr_block  = data.aws_vpc.this.cidr_block
      from_port   = 445
      ip_protocol = "tcp"
      to_port     = 445
    },
    {
      description = "iSCSI access"
      cidr_block  = data.aws_vpc.this.cidr_block
      from_port   = 3260
      ip_protocol = "tcp"
      to_port     = 3260
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
    Name        = "${var.namespace}-${var.environment}-fsx-ontap-sg"
    Environment = var.environment
    FSxType     = "ontap"
  }
}

module "fsx_ontap" {
  source = "../.."

  name        = "example-ontap-fsx"
  environment = "prod"
  fsx_type    = "ontap"

  # Network Configuration
  vpc_id              = data.aws_vpc.this.id
  subnet_ids          = data.aws_subnets.private.ids
  preferred_subnet_id = data.aws_subnets.private.ids[0]
  security_group_ids  = [module.security_group.id]

  # FSx Configuration
  storage_capacity = 1024
  deployment_type  = "MULTI_AZ_1"
  storage_type     = "SSD"

  # ONTAP Configuration
  ontap_configuration = {
    throughput_capacity_per_ha_pair = 512
    ha_pairs                        = 1
  }

  # Backup Configuration
  backup_configuration = {
    automatic_backup_retention_days   = 14
    daily_automatic_backup_start_time = "01:00"
    skip_final_backup                 = true
  }

  weekly_maintenance_start_time = "6:02:00"

  tags = module.tags.tags
}
