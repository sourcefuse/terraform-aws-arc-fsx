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
  version = "1.2.3"

  environment = var.environment
  project     = var.namespace

  extra_tags = {
    RepoName = "terraform-aws-arc-fsx"
    Project     = "HPC Workload"
    DataSource  = "S3"
  }
}

module "security_group" {
  source = "sourcefuse/arc-security-group/aws"
  version = "0.0.3"

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
resource "aws_s3_bucket" "this" {
  bucket = "example-fsx-lustre-bucket-${random_id.bucket_suffix.hex}"
  
  tags = module.tags.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

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
  storage_capacity            = 1200 #GiB
  deployment_type            = "PERSISTENT_2"
  per_unit_storage_throughput = 250
  storage_type               = "SSD"

  # S3 Integration
  # import_path              = "s3://${aws_s3_bucket.this.id}/import"
  # export_path              = "s3://${aws_s3_bucket.this.id}/export"
  # imported_file_chunk_size = 1024
  # auto_import_policy       = "NEW_CHANGED"
  data_compression_type    = "LZ4"

  # Data Repository Associations
  data_repository_associations = {
    main = {
      data_repository_path = "s3://${aws_s3_bucket.this.id}/import"
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

  # Backup Configuration
  automatic_backup_retention_days   = 30
  daily_automatic_backup_start_time = "02:00"
  weekly_maintenance_start_time     = "7:03:00"

  tags = module.tags.tags
}


