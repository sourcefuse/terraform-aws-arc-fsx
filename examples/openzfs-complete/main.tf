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
    Project  = "Complete OpenZFS Example"
    Features = "Volumes-Snapshots-NFS-Compression"
  }
}


module "security_group" {
  source = "sourcefuse/arc-security-group/aws"

  name   = "${var.namespace}-${var.environment}-fsx-openzfs-sg"
  vpc_id = data.aws_vpc.this.id

  ingress_rules = [
    {
      description = "NFS access"
      cidr_block  = data.aws_vpc.this.cidr_block
      from_port   = 2049
      ip_protocol = "tcp"
      to_port     = 2049
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
    Name        = "${var.namespace}-${var.environment}-fsx-openzfs-sg"
    Environment = var.environment
    FSxType     = "openzfs"
  }
}

module "fsx_openzfs_complete" {
  source = "../.."

  name        = "complete-openzfs-example"
  environment = "prod"
  fsx_type    = "openzfs"

  # Network Configuration
  vpc_id             = data.aws_vpc.this.id
  subnet_ids         = [data.aws_subnets.private.ids[0]]
  security_group_ids = [module.security_group.id]

  # FSx Configuration
  storage_capacity    = 64
  deployment_type     = "SINGLE_AZ_1"
  throughput_capacity = 64
  storage_type        = "SSD"

  # OpenZFS Configuration
  openzfs_configuration = {
    root_volume_configuration = {
      copy_tags_to_snapshots = true
      data_compression_type  = "ZSTD"
      read_only              = false
      record_size_kib        = 128
      nfs_exports = [{
        client_configurations = [{
          clients = "10.0.0.0/16"
          options = ["rw", "crossmnt", "no_root_squash"]
        }]
      }]
    }
    volumes = {
      app_data = {
        name                       = "application_data"
        data_compression_type      = "ZSTD"
        record_size_kib            = 64
        storage_capacity_quota_gib = 50
        nfs_exports = [{
          client_configurations = [{
            clients = "10.0.0.0/16"
            options = ["rw", "no_root_squash"]
          }]
        }]
        user_and_group_quotas = [{
          id                         = 1001
          storage_capacity_quota_gib = 10
          type                       = "USER"
        }]
        tags = {
          Purpose = "AppData"
        }
      }
    }
    snapshots = {
      app_data_snapshot = {
        name        = "app-data-daily-snapshot"
        volume_name = "app_data"
      }
    }
  }

  # Manual Backups
  fsx_backups = {
    monthly_backup = {}
  }

  tags = module.tags.tags
}
