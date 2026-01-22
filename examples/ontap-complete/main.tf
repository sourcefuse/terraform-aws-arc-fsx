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
    Project  = "Complete ONTAP Example"
    Features = "SVM-Volumes-Backups"
  }
}


module "security_group" {
  source = "sourcefuse/arc-security-group/aws"

  name   = "${var.namespace}-${var.environment}-fsx-ontap-complete-sg"
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
    Name        = "${var.namespace}-${var.environment}-fsx-ontap-complete-sg"
    Environment = var.environment
    FSxType     = "ontap"
  }
}

module "fsx_ontap_complete" {
  source = "../.."

  name        = "complete-ontap-example"
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
    storage_virtual_machines = {
      svm1 = {
        name                       = "svm-production"
        root_volume_security_style = "UNIX"
      }
      svm2 = {
        name                       = "svm-development"
        root_volume_security_style = "NTFS"
      }
    }
    volumes = {
      prod_data = {
        name                       = "production_data"
        svm_name                   = "svm1"
        size_in_megabytes          = 102400 # 100GB
        storage_efficiency_enabled = true
        junction_path              = "/prod_data"
        security_style             = "UNIX"
        tiering_policy = {
          name           = "AUTO"
          cooling_period = 31
        }
      }
      dev_data = {
        name                       = "development_data"
        svm_name                   = "svm2"
        size_in_megabytes          = 51200
        storage_efficiency_enabled = true
        junction_path              = "/dev_data"
        security_style             = "NTFS"
      }
    }
  }

  # Manual Backups
  fsx_backups = {
    weekly_backup = {}
  }

  tags = module.tags.tags
}
