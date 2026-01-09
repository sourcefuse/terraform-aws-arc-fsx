################################################################################
# General Configuration
################################################################################

variable "create" {
  description = "Whether to create FSx resources"
  type        = bool
  default     = true
}

variable "name" {
  description = "Name prefix for FSx resources"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

################################################################################
# FSx Configuration
################################################################################

variable "fsx_type" {
  description = "Type of FSx file system to create"
  type        = string
  default     = "windows"

  validation {
    condition     = contains(["windows", "lustre", "ontap", "openzfs"], var.fsx_type)
    error_message = "FSx type must be one of: windows, lustre, ontap, openzfs."
  }
}

variable "storage_capacity" {
  description = "Storage capacity of the file system in GiB"
  type        = number

  validation {
    condition     = var.storage_capacity >= 32
    error_message = "Storage capacity must be at least 32 GiB."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for the file system"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the file system will be created"
  type        = string
}

variable "throughput_capacity" {
  description = "Throughput capacity in MB/s"
  type        = number
  default     = null
}

variable "deployment_type" {
  description = "Deployment type for the file system"
  type        = string
  default     = null
}

variable "preferred_subnet_id" {
  description = "Preferred subnet ID for multi-AZ deployments"
  type        = string
  default     = null
}

variable "storage_type" {
  description = "Storage type (SSD or HDD)"
  type        = string
  default     = "SSD"

  validation {
    condition     = contains(["SSD", "HDD"], var.storage_type)
    error_message = "Storage type must be either SSD or HDD."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "copy_tags_to_backups" {
  description = "Whether to copy tags to backups"
  type        = bool
  default     = true
}

variable "skip_final_backup" {
  description = "Whether to skip final backup when deleting"
  type        = bool
  default     = false
}

variable "final_backup_tags" {
  description = "Tags to apply to final backup"
  type        = map(string)
  default     = {}
}

variable "automatic_backup_retention_days" {
  description = "Number of days to retain automatic backups"
  type        = number
  default     = 0

  validation {
    condition     = var.automatic_backup_retention_days >= 0 && var.automatic_backup_retention_days <= 90
    error_message = "Automatic backup retention days must be between 0 and 90."
  }
}

variable "daily_automatic_backup_start_time" {
  description = "Daily automatic backup start time (HH:MM)"
  type        = string
  default     = null

  validation {
    condition     = var.daily_automatic_backup_start_time == null || can(regex("^([01]?[0-9]|2[0-3]):[0-5][0-9]$", var.daily_automatic_backup_start_time))
    error_message = "Daily automatic backup start time must be in HH:MM format."
  }
}

variable "weekly_maintenance_start_time" {
  description = "Weekly maintenance start time (d:HH:MM)"
  type        = string
  default     = null

  validation {
    condition     = var.weekly_maintenance_start_time == null || can(regex("^[1-7]:([01]?[0-9]|2[0-3]):[0-5][0-9]$", var.weekly_maintenance_start_time))
    error_message = "Weekly maintenance start time must be in d:HH:MM format where d is 1-7."
  }
}

################################################################################
# Windows File Server Specific
################################################################################

variable "active_directory_id" {
  description = "AWS Managed Microsoft AD ID"
  type        = string
  default     = null
}

variable "self_managed_active_directory" {
  description = "Self-managed Active Directory configuration"
  type = object({
    dns_ips                                = list(string)
    domain_name                            = string
    password                               = string
    username                               = string
    file_system_administrators_group       = optional(string)
    organizational_unit_distinguished_name = optional(string)
  })
  default = null
}

variable "audit_log_configuration" {
  description = "Audit log configuration for Windows file systems"
  type = object({
    file_access_audit_log_level       = string
    file_share_access_audit_log_level = string
    audit_log_destination             = optional(string)
  })
  default = null
}

################################################################################
# Lustre Specific
################################################################################

variable "per_unit_storage_throughput" {
  description = "Per unit storage throughput for Lustre"
  type        = number
  default     = null
}

variable "import_path" {
  description = "S3 bucket path for Lustre import"
  type        = string
  default     = null
}

variable "export_path" {
  description = "S3 bucket path for Lustre export"
  type        = string
  default     = null
}

variable "imported_file_chunk_size" {
  description = "Chunk size for imported files (MiB)"
  type        = number
  default     = null
}

variable "auto_import_policy" {
  description = "Auto import policy for Lustre"
  type        = string
  default     = null
}

variable "data_compression_type" {
  description = "Data compression type"
  type        = string
  default     = null
}

variable "drive_cache_type" {
  description = "Drive cache type for Lustre"
  type        = string
  default     = null
}

variable "log_configuration" {
  description = "Log configuration for Lustre"
  type = object({
    destination = string
    level       = string
  })
  default = null
}

variable "metadata_configuration" {
  type = object({
    mode = string
    iops = optional(number)
  })
  default = null
}

variable "root_squash_configuration" {
  type = object({
    root_squash    = optional(string)
    no_squash_nids = optional(list(string))
  })
  default = null
}

variable "data_read_cache_configuration" {
  type = object({
    sizing_mode = string
    size        = optional(number)
  })
  default = null
}

variable "efa_enabled" {
  type    = bool
  default = null
}

variable "data_repository_associations" {
  description = "Data repository associations for Lustre"
  type = map(object({
    data_repository_path             = string
    file_system_path                 = string
    batch_import_meta_data_on_create = optional(bool)
    imported_file_chunk_size         = optional(number)
    s3 = optional(object({
      auto_export_policy = object({
        events = list(string)
      })
      auto_import_policy = object({
        events = list(string)
      })
    }))
  }))
  default = {}
}

################################################################################
# ONTAP Specific
################################################################################

variable "fsx_admin_password" {
  description = "FSx admin password for ONTAP"
  type        = string
  default     = null
  sensitive   = true
}

variable "ha_pairs" {
  description = "Number of HA pairs for ONTAP"
  type        = number
  default     = null
}

variable "throughput_capacity_per_ha_pair" {
  description = "Throughput capacity per HA pair for ONTAP"
  type        = number
  default     = null
}

################################################################################
# OpenZFS Specific
################################################################################

variable "disk_iops_configuration" {
  description = "Disk IOPS configuration for OpenZFS"
  type = object({
    mode = string
    iops = optional(number)
  })
  default = null
}

variable "root_volume_configuration" {
  description = "Root volume configuration for OpenZFS"
  type = object({
    copy_tags_to_snapshots = optional(bool)
    data_compression_type  = optional(string)
    read_only              = optional(bool)
    record_size_kib        = optional(number)
    nfs_exports = optional(list(object({
      client_configurations = list(object({
        clients = string
        options = list(string)
      }))
    })))
    user_and_group_quotas = optional(list(object({
      id                         = number
      storage_capacity_quota_gib = number
      type                       = string
    })))
  })
  default = null
}

################################################################################
# Security Group Configuration
################################################################################

variable "security_group_ids" {
  description = "List of security group IDs to use for FSx"
  type        = list(string)
  default     = []
}

################################################################################
# IAM Configuration
################################################################################

variable "create_iam_role" {
  description = "Whether to create IAM role for FSx"
  type        = bool
  default     = false
}

variable "iam_policy_arns" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "custom_iam_policy" {
  description = "Custom IAM policy JSON for FSx role"
  type        = string
  default     = null
}

################################################################################
# File Cache Configuration
################################################################################

variable "create_file_cache" {
  description = "Whether to create FSx File Cache"
  type        = bool
  default     = false
}

variable "file_cache_type" {
  description = "Type of file cache (LUSTRE)"
  type        = string
  default     = "LUSTRE"
}

variable "file_cache_type_version" {
  description = "Version of the file cache type"
  type        = string
  default     = "2.12"
}

variable "file_cache_storage_capacity" {
  description = "Storage capacity of the file cache in GiB"
  type        = number
  default     = 1200
}

variable "copy_tags_to_data_repository_associations" {
  description = "Whether to copy tags to data repository associations"
  type        = bool
  default     = true
}

variable "file_cache_lustre_configuration" {
  description = "Lustre configuration for file cache"
  type = object({
    deployment_type               = string
    per_unit_storage_throughput   = number
    weekly_maintenance_start_time = optional(string)
    metadata_configuration = optional(object({
      storage_capacity = number
    }))
  })
  default = null
}

variable "file_cache_data_repository_associations" {
  description = "Data repository associations for file cache"
  type = map(object({
    data_repository_path           = string
    file_cache_path                = string
    data_repository_subdirectories = optional(list(string))
    nfs = optional(object({
      version = string
      dns_ips = optional(list(string))
    }))
  }))
  default = {}
}

################################################################################
# ONTAP Storage Virtual Machines
################################################################################

variable "ontap_storage_virtual_machines" {
  description = "ONTAP Storage Virtual Machines configuration"
  type = map(object({
    name                       = string
    svm_admin_password         = optional(string)
    root_volume_security_style = optional(string)
    active_directory_configuration = optional(object({
      netbios_name                           = string
      dns_ips                                = list(string)
      domain_name                            = string
      password                               = string
      username                               = string
      file_system_administrators_group       = optional(string)
      organizational_unit_distinguished_name = optional(string)
    }))
  }))
  default = {}
}

################################################################################
# ONTAP Volumes
################################################################################

# variable "ontap_volumes" {
#   description = "ONTAP Volumes configuration"
#   type = map(object({
#     name                       = string
#     svm_name                   = string
#     size_in_megabytes          = number
#     storage_efficiency_enabled = optional(bool)
#     junction_path              = optional(string)
#     security_style             = optional(string)
#     volume_type                = optional(string)
#     ontap_volume_type          = optional(string)
#     copy_tags_to_backups       = optional(bool)
#     skip_final_backup          = optional(bool)
#     final_backup_tags          = optional(map(string))
#     tiering_policy = optional(object({
#       cooling_period = optional(number)
#       name           = optional(string)
#     }))
#     snapshot_policy = optional(object({
#       snapshot_policy_name = string
#     }))
#   }))
#   default = {}
# }

variable "ontap_volumes" {
  description = "ONTAP volumes configuration. Keys are logical volume identifiers."

  type = map(object({

    # Required
    name     = string
    svm_name = string

    # Size (EXACTLY one of these should be set)
    size_in_megabytes = optional(number)
    size_in_bytes     = optional(number)

    # General volume settings
    junction_path     = optional(string)
    security_style    = optional(string) # UNIX | NTFS | MIXED
    volume_style      = optional(string) # FLEXVOL | FLEXGROUP
    ontap_volume_type = optional(string) # RW | DP
    snapshot_policy   = optional(string)

    # Backup behavior
    copy_tags_to_backups = optional(bool)
    skip_final_backup    = optional(bool)
    final_backup_tags    = optional(map(string))

    # Storage efficiency (REQUIRED by AWS, default handled in module)    
    storage_efficiency_enabled = optional(bool)

    # Tiering policy
    tiering_policy = optional(object({
      name           = optional(string) # SNAPSHOT_ONLY | AUTO | ALL | NONE
      cooling_period = optional(number) # 2–183 depending on policy
    }))

    # Aggregate configuration (FLEXGROUP only)    
    aggregate_configuration = optional(object({
      aggregates                 = optional(list(string)) # aggr1, aggr2...
      constituents_per_aggregate = optional(number)
    }))

    # SnapLock configuration    
    snaplock_configuration = optional(object({
      snaplock_type              = string # COMPLIANCE | ENTERPRISE
      audit_log_volume           = optional(bool)
      privileged_delete          = optional(string) # DISABLED | ENABLED | PERMANENTLY_DISABLED
      volume_append_mode_enabled = optional(bool)
      autocommit_period = optional(object({
        type  = string # MINUTES | HOURS | DAYS | MONTHS | YEARS | NONE
        value = optional(number)
      }))
      retention_period = optional(object({
        default_retention = object({
          type  = string # SECONDS | MINUTES | HOURS | DAYS | MONTHS | YEARS | INFINITE | UNSPECIFIED
          value = optional(number)
        })
        maximum_retention = object({
          type  = string
          value = optional(number)
        })
        minimum_retention = object({
          type  = string
          value = optional(number)
        })
      }))
    }))

    # Advanced / less common    
    bypass_snaplock_enterprise_retention = optional(bool)
  }))

  default = {}
}


################################################################################
# OpenZFS Volumes
################################################################################

# variable "openzfs_volumes" {
#   description = "OpenZFS Volumes configuration"
#   type = map(object({
#     name                             = string
#     parent_volume_id                 = optional(string)
#     storage_capacity_quota_gib       = optional(number)
#     storage_capacity_reservation_gib = optional(number)
#     copy_tags_to_snapshots           = optional(bool)
#     data_compression_type            = optional(string)
#     read_only                        = optional(bool)
#     record_size_kib                  = optional(number)
#     nfs_exports = optional(list(object({
#       client_configurations = list(object({
#         clients = string
#         options = list(string)
#       }))
#     })))
#     user_and_group_quotas = optional(list(object({
#       id                         = number
#       storage_capacity_quota_gib = number
#       type                       = string
#     })))
#   }))
#   default = {}
# }

variable "openzfs_volumes" {
  description = "OpenZFS Volumes configuration"
  type = map(object({
    name             = string
    parent_volume_id = optional(string)

    copy_tags_to_snapshots = optional(bool)
    data_compression_type  = optional(string)
    read_only              = optional(bool)
    record_size_kib        = optional(number)

    storage_capacity_quota_gib       = optional(number)
    storage_capacity_reservation_gib = optional(number)

    delete_volume_options = optional(list(string))

    origin_snapshot = optional(object({
      copy_strategy = string
      snapshot_arn  = string
    }))

    nfs_exports = optional(list(object({
      client_configurations = list(object({
        clients = string
        options = list(string)
      }))
    })))

    user_and_group_quotas = optional(list(object({
      id                         = number
      storage_capacity_quota_gib = number
      type                       = string
    })))

    tags = optional(map(string))
  }))
  default = {}
}


################################################################################
# OpenZFS Snapshots
################################################################################

variable "openzfs_snapshots" {
  description = "OpenZFS Snapshots configuration"
  type = map(object({
    name        = string
    volume_name = string
  }))
  default = {}
}

################################################################################
# FSx Backups
################################################################################

variable "fsx_backups" {
  description = "FSx Backups configuration"
  type = map(object({
    volume_id = optional(string)
  }))
  default = {}
}
