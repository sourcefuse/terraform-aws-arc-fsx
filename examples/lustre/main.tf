################################################################
## defaults
################################################################
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.5.0, < 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
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
  version = "1.2.7"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    RepoName   = "terraform-aws-arc-fsx"
    Project    = "HPC Workload"
    DataSource = "S3"
  }
}

module "security_group" {
  source  = "sourcefuse/arc-security-group/aws"
  version = "0.0.4"

  name   = "${var.namespace}-${var.environment}-fsx-lustre-sg"
  vpc_id = data.aws_vpc.this.id

  ingress_rules = [
    {
      description = "Lustre client access"
      cidr_block  = data.aws_vpc.this.cidr_block
      from_port   = 988
      ip_protocol = "tcp"
      to_port     = 988
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
    Name        = "${var.namespace}-${var.environment}-fsx-lustre-sg"
    Environment = var.environment
    FSxType     = "lustre"
  }
}

# Simple S3 bucket without the problematic module
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

module "s3" {
  source        = "sourcefuse/arc-s3/aws"
  version       = "0.0.7"
  name          = "${var.namespace}-${var.environment}-lustre-s3-logs-${random_id.bucket_suffix.hex}"
  force_destroy = true
  tags          = module.tags.tags
}

################################################################################
## FSX-Lustre
################################################################################
module "fsx_lustre" {
  source = "../.."

  name        = "example-lustre-fsx"
  environment = "prod"
  fsx_type    = "lustre"

  # Network Configuration
  vpc_id             = data.aws_vpc.this.id
  subnet_ids         = [data.aws_subnets.private.ids[0]]
  security_group_ids = [module.security_group.id]

  # FSx Configuration
  storage_capacity = 1200 #GiB
  deployment_type  = "PERSISTENT_2"
  storage_type     = "SSD"

  # Lustre Configuration
  lustre_configuration = {
    per_unit_storage_throughput = 250
    data_compression_type       = "LZ4"
    data_repository_associations = {
      main = {
        data_repository_path = "s3://${module.s3.bucket_id}/import"
        file_system_path     = "/data"
        s3 = {
          auto_export_policy = {
            events = ["NEW", "CHANGED", "DELETED"]
          }
          auto_import_policy = {
            events = ["NEW", "CHANGED", "DELETED"]
          }
        }
      }
    }
  }

  # Backup Configuration
  backup_configuration = {
    automatic_backup_retention_days   = 30
    daily_automatic_backup_start_time = "02:00"
  }

  weekly_maintenance_start_time = "7:03:00"

  tags = module.tags.tags
}
