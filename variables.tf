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
# Security Group Configuration
################################################################################

variable "security_group_ids" {
  description = "List of security group IDs to use for FSx"
  type        = list(string)
  default     = []
}

################################################################################
# Backup Configuration
################################################################################

variable "backup_configuration" {
  description = "Backup configuration for FSx file systems"
  type = object({
    copy_tags_to_backups              = optional(bool, true)
    skip_final_backup                 = optional(bool, false)
    final_backup_tags                 = optional(map(string), {})
    automatic_backup_retention_days   = optional(number, 0)
    daily_automatic_backup_start_time = optional(string, null)
  })
  default = {}

  validation {
    condition = var.backup_configuration.automatic_backup_retention_days == null || (
      var.backup_configuration.automatic_backup_retention_days >= 0 &&
      var.backup_configuration.automatic_backup_retention_days <= 90
    )
    error_message = "Automatic backup retention days must be between 0 and 90."
  }

  validation {
    condition = var.backup_configuration.daily_automatic_backup_start_time == null || can(
      regex("^([01]?[0-9]|2[0-3]):[0-5][0-9]$", var.backup_configuration.daily_automatic_backup_start_time)
    )
    error_message = "Daily automatic backup start time must be in HH:MM format."
  }
}

################################################################################
# Windows File Server Configuration
################################################################################

variable "windows_configuration" {
  description = "Windows File Server specific configuration"
  type = object({
    active_directory_id = optional(string, null)
    self_managed_active_directory = optional(object({
      dns_ips                                = list(string)
      domain_name                            = string
      password                               = string
      username                               = string
      file_system_administrators_group       = optional(string)
      organizational_unit_distinguished_name = optional(string)
    }), null)
    audit_log_configuration = optional(object({
      file_access_audit_log_level       = string
      file_share_access_audit_log_level = string
      audit_log_destination             = optional(string)
    }), null)
  })
  default = {}
}

################################################################################
# Lustre Configuration
################################################################################

variable "lustre_configuration" {
  description = "Lustre file system specific configuration"
  type = object({
    per_unit_storage_throughput = optional(number, null)
    import_path                 = optional(string, null)
    export_path                 = optional(string, null)
    imported_file_chunk_size    = optional(number, null)
    auto_import_policy          = optional(string, null)
    data_compression_type       = optional(string, null)
    drive_cache_type            = optional(string, null)
    efa_enabled                 = optional(bool, null)
    log_configuration = optional(object({
      destination = string
      level       = string
    }), null)
    metadata_configuration = optional(object({
      mode = string
      iops = optional(number)
    }), null)
    root_squash_configuration = optional(object({
      root_squash    = optional(string)
      no_squash_nids = optional(list(string))
    }), null)
    data_read_cache_configuration = optional(object({
      sizing_mode = string
      size        = optional(number)
    }), null)
    data_repository_associations = optional(map(object({
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
    })), {})
  })
  default = {}
}

################################################################################
# ONTAP Configuration
################################################################################

variable "ontap_configuration" {
  description = "ONTAP file system specific configuration"
  type = object({
    fsx_admin_password              = optional(string, null)
    ha_pairs                        = optional(number, null)
    throughput_capacity_per_ha_pair = optional(number, null)
    storage_virtual_machines = optional(map(object({
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
    })), {})
    volumes = optional(map(object({
      name                       = string
      svm_name                   = string
      size_in_megabytes          = optional(number)
      size_in_bytes              = optional(number)
      junction_path              = optional(string)
      security_style             = optional(string)
      volume_style               = optional(string)
      ontap_volume_type          = optional(string)
      snapshot_policy            = optional(string)
      copy_tags_to_backups       = optional(bool)
      skip_final_backup          = optional(bool)
      final_backup_tags          = optional(map(string))
      storage_efficiency_enabled = optional(bool)
      tiering_policy = optional(object({
        name           = optional(string)
        cooling_period = optional(number)
      }))
      aggregate_configuration = optional(object({
        aggregates                 = optional(list(string))
        constituents_per_aggregate = optional(number)
      }))
      snaplock_configuration = optional(object({
        snaplock_type              = string
        audit_log_volume           = optional(bool)
        privileged_delete          = optional(string)
        volume_append_mode_enabled = optional(bool)
        autocommit_period = optional(object({
          type  = string
          value = optional(number)
        }))
        retention_period = optional(object({
          default_retention = object({
            type  = string
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
      bypass_snaplock_enterprise_retention = optional(bool)
    })), {})
  })
  default = {}
}

################################################################################
# OpenZFS Configuration
################################################################################

variable "openzfs_configuration" {
  description = "OpenZFS file system specific configuration"
  type = object({
    disk_iops_configuration = optional(object({
      mode = string
      iops = optional(number)
    }), null)
    root_volume_configuration = optional(object({
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
    }), null)
    volumes = optional(map(object({
      name                             = string
      parent_volume_id                 = optional(string)
      copy_tags_to_snapshots           = optional(bool)
      data_compression_type            = optional(string)
      read_only                        = optional(bool)
      record_size_kib                  = optional(number)
      storage_capacity_quota_gib       = optional(number)
      storage_capacity_reservation_gib = optional(number)
      delete_volume_options            = optional(list(string))
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
    })), {})
    snapshots = optional(map(object({
      name        = string
      volume_name = string
    })), {})
  })
  default = {}
}

################################################################################
# IAM Configuration
################################################################################

variable "iam_configuration" {
  description = "IAM configuration for FSx"
  type = object({
    create_iam_role   = optional(bool, false)
    iam_policy_arns   = optional(list(string), [])
    custom_iam_policy = optional(string, null)
  })
  default = {}
}

################################################################################
# File Cache Configuration
################################################################################

variable "file_cache_configuration" {
  description = "FSx File Cache configuration"
  type = object({
    create_file_cache                         = optional(bool, false)
    file_cache_type                           = optional(string, "LUSTRE")
    file_cache_type_version                   = optional(string, "2.12")
    file_cache_storage_capacity               = optional(number, 1200)
    copy_tags_to_data_repository_associations = optional(bool, true)
    lustre_configuration = optional(object({
      deployment_type               = string
      per_unit_storage_throughput   = number
      weekly_maintenance_start_time = optional(string)
      metadata_configuration = optional(object({
        storage_capacity = number
      }))
    }), null)
    data_repository_associations = optional(map(object({
      data_repository_path           = string
      file_cache_path                = string
      data_repository_subdirectories = optional(list(string))
      nfs = optional(object({
        version = string
        dns_ips = optional(list(string))
      }))
    })), {})
  })
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
