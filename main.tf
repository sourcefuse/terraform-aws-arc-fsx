################################################################################
# FSx File System
################################################################################

resource "aws_fsx_windows_file_system" "this" {
  count = var.create && var.fsx_type == "windows" ? 1 : 0

  storage_capacity     = var.storage_capacity
  subnet_ids           = var.subnet_ids
  throughput_capacity  = var.throughput_capacity
  deployment_type      = var.deployment_type
  preferred_subnet_id  = var.preferred_subnet_id
  storage_type         = var.storage_type
  kms_key_id           = var.kms_key_id
  copy_tags_to_backups = var.copy_tags_to_backups
  skip_final_backup    = var.skip_final_backup
  final_backup_tags    = var.final_backup_tags

  active_directory_id = var.active_directory_id

  dynamic "self_managed_active_directory" {
    for_each = var.self_managed_active_directory != null ? [var.self_managed_active_directory] : []
    content {
      dns_ips                                = self_managed_active_directory.value.dns_ips
      domain_name                            = self_managed_active_directory.value.domain_name
      password                               = self_managed_active_directory.value.password
      username                               = self_managed_active_directory.value.username
      file_system_administrators_group       = lookup(self_managed_active_directory.value, "file_system_administrators_group", null)
      organizational_unit_distinguished_name = lookup(self_managed_active_directory.value, "organizational_unit_distinguished_name", null)
    }
  }

  dynamic "audit_log_configuration" {
    for_each = var.audit_log_configuration != null ? [var.audit_log_configuration] : []
    content {
      file_access_audit_log_level       = audit_log_configuration.value.file_access_audit_log_level
      file_share_access_audit_log_level = audit_log_configuration.value.file_share_access_audit_log_level
      audit_log_destination             = lookup(audit_log_configuration.value, "audit_log_destination", null)
    }
  }

  automatic_backup_retention_days   = var.automatic_backup_retention_days
  daily_automatic_backup_start_time = var.daily_automatic_backup_start_time
  weekly_maintenance_start_time     = var.weekly_maintenance_start_time
  security_group_ids                = local.security_group_ids

  tags = local.tags

  timeouts {
    delete = "240m"
  }
}

# resource "aws_fsx_lustre_file_system" "this" {
#   count = var.create && var.fsx_type == "lustre" ? 1 : 0

#   storage_capacity            = var.storage_capacity
#   subnet_ids                  = var.subnet_ids
#   deployment_type             = var.deployment_type
#   storage_type                = var.storage_type
#   kms_key_id                  = var.kms_key_id
#   per_unit_storage_throughput = var.per_unit_storage_throughput
#   copy_tags_to_backups        = var.copy_tags_to_backups
#   skip_final_backup           = var.skip_final_backup
#   final_backup_tags           = var.final_backup_tags

#   import_path              = var.import_path
#   export_path              = var.export_path
#   imported_file_chunk_size = var.imported_file_chunk_size
#   auto_import_policy       = var.auto_import_policy
#   data_compression_type    = var.data_compression_type
#   drive_cache_type         = var.drive_cache_type

#   dynamic "log_configuration" {
#     for_each = var.log_configuration != null ? [var.log_configuration] : []
#     content {
#       destination = log_configuration.value.destination
#       level       = log_configuration.value.level
#     }
#   }

#   # automatic_backup_retention_days   = var.automatic_backup_retention_days
#   automatic_backup_retention_days = local.is_lustre_s3_linked ? 0 : var.automatic_backup_retention_days

#   # daily_automatic_backup_start_time = var.daily_automatic_backup_start_time
#   daily_automatic_backup_start_time = local.is_lustre_s3_linked ? null : var.daily_automatic_backup_start_time
#   weekly_maintenance_start_time     = var.weekly_maintenance_start_time
#   security_group_ids                = local.security_group_ids

#   tags = local.tags
# }
resource "aws_fsx_lustre_file_system" "this" {
  count = var.create && local.is_lustre ? 1 : 0

  # ---------------------------------------------------------------------------
  # REQUIRED / CORE
  # ---------------------------------------------------------------------------
  subnet_ids       = var.subnet_ids
  storage_capacity = var.storage_capacity

  deployment_type = var.deployment_type
  storage_type    = var.storage_type
  kms_key_id      = var.kms_key_id

  security_group_ids = local.security_group_ids
  tags               = local.tags

  # ---------------------------------------------------------------------------
  # PERFORMANCE
  # ---------------------------------------------------------------------------
  per_unit_storage_throughput = var.per_unit_storage_throughput
  throughput_capacity         = var.throughput_capacity
  efa_enabled                 = var.efa_enabled

  # ---------------------------------------------------------------------------
  # BACKUPS (auto-disabled for S3-linked)
  # ---------------------------------------------------------------------------
  automatic_backup_retention_days = local.is_lustre_s3_linked ? 0 : var.automatic_backup_retention_days

  daily_automatic_backup_start_time = local.is_lustre_s3_linked ? null : var.daily_automatic_backup_start_time

  weekly_maintenance_start_time = var.weekly_maintenance_start_time

  copy_tags_to_backups = var.copy_tags_to_backups
  skip_final_backup    = var.skip_final_backup
  final_backup_tags    = var.final_backup_tags

  # ---------------------------------------------------------------------------
  # LUSTRE CONFIGURATION (ONLY for non-PERSISTENT_2)
  # ---------------------------------------------------------------------------
  import_path = local.enable_lustre_config_at_create ? var.import_path : null

  export_path = local.enable_lustre_config_at_create ? var.export_path : null

  imported_file_chunk_size = local.enable_lustre_config_at_create ? var.imported_file_chunk_size : null

  auto_import_policy = local.enable_lustre_config_at_create ? var.auto_import_policy : null

  data_compression_type = var.data_compression_type
  drive_cache_type      = var.drive_cache_type

  # ---------------------------------------------------------------------------
  # LOG CONFIGURATION
  # ---------------------------------------------------------------------------
  dynamic "log_configuration" {
    for_each = var.log_configuration != null ? [var.log_configuration] : []
    content {
      destination = log_configuration.value.destination
      level       = log_configuration.value.level
    }
  }

  # ---------------------------------------------------------------------------
  # METADATA CONFIGURATION (PERSISTENT_2 ONLY)
  # ---------------------------------------------------------------------------
  dynamic "metadata_configuration" {
    for_each = local.is_persistent_2 && var.metadata_configuration != null ? [var.metadata_configuration] : []
    content {
      mode = metadata_configuration.value.mode
      iops = lookup(metadata_configuration.value, "iops", null)
    }
  }

  # ---------------------------------------------------------------------------
  # ROOT SQUASH
  # ---------------------------------------------------------------------------
  dynamic "root_squash_configuration" {
    for_each = var.root_squash_configuration != null ? [var.root_squash_configuration] : []
    content {
      root_squash    = lookup(root_squash_configuration.value, "root_squash", null)
      no_squash_nids = lookup(root_squash_configuration.value, "no_squash_nids", null)
    }
  }

  # ---------------------------------------------------------------------------
  # DATA READ CACHE (INTELLIGENT_TIERING)
  # ---------------------------------------------------------------------------
  dynamic "data_read_cache_configuration" {
    for_each = var.data_read_cache_configuration != null ? [var.data_read_cache_configuration] : []
    content {
      sizing_mode = data_read_cache_configuration.value.sizing_mode
      size        = lookup(data_read_cache_configuration.value, "size", null)
    }
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}


resource "random_id" "fsx" {
  byte_length = 4
}

resource "random_password" "fsx_admin" {
  count            = var.create && var.fsx_type == "ontap" && var.fsx_admin_password == null ? 1 : 0
  length           = 32
  special          = true
  override_special = "!@#%^*()-_=+[]{}"
}

resource "aws_ssm_parameter" "fsx_admin" {
  count = length(random_password.fsx_admin) > 0 ? 1 : 0

  name  = "/fsx/ontap/${var.environment}/fsxadmin-${random_id.fsx.hex}"
  type  = "SecureString"
  value = random_password.fsx_admin[0].result

  tags = local.tags
}

resource "aws_fsx_ontap_file_system" "this" {
  count = var.create && var.fsx_type == "ontap" ? 1 : 0

  storage_capacity    = var.storage_capacity
  subnet_ids          = var.subnet_ids
  deployment_type     = var.deployment_type
  throughput_capacity = var.throughput_capacity
  preferred_subnet_id = var.preferred_subnet_id
  kms_key_id          = var.kms_key_id
  storage_type        = var.storage_type

  # fsx_admin_password              = var.fsx_admin_password
  fsx_admin_password              = coalesce(var.fsx_admin_password, try(random_password.fsx_admin[0].result, null))
  ha_pairs                        = var.ha_pairs
  throughput_capacity_per_ha_pair = var.throughput_capacity_per_ha_pair

  automatic_backup_retention_days   = var.automatic_backup_retention_days
  daily_automatic_backup_start_time = var.daily_automatic_backup_start_time
  weekly_maintenance_start_time     = var.weekly_maintenance_start_time
  security_group_ids                = local.security_group_ids

  tags = local.tags
}

# resource "aws_fsx_openzfs_file_system" "this" {
#   count = var.create && var.fsx_type == "openzfs" ? 1 : 0

#   storage_capacity     = var.storage_capacity
#   subnet_ids           = var.subnet_ids
#   deployment_type      = var.deployment_type
#   throughput_capacity  = var.throughput_capacity
#   storage_type         = var.storage_type
#   kms_key_id           = var.kms_key_id
#   copy_tags_to_backups = var.copy_tags_to_backups
#   skip_final_backup    = var.skip_final_backup
#   final_backup_tags    = var.final_backup_tags

#   dynamic "disk_iops_configuration" {
#     for_each = var.disk_iops_configuration != null ? [var.disk_iops_configuration] : []
#     content {
#       mode = disk_iops_configuration.value.mode
#       iops = lookup(disk_iops_configuration.value, "iops", null)
#     }
#   }

#   dynamic "root_volume_configuration" {
#     for_each = var.root_volume_configuration != null ? [var.root_volume_configuration] : []
#     content {
#       copy_tags_to_snapshots = lookup(root_volume_configuration.value, "copy_tags_to_snapshots", null)
#       data_compression_type  = lookup(root_volume_configuration.value, "data_compression_type", null)
#       read_only              = lookup(root_volume_configuration.value, "read_only", null)
#       record_size_kib        = lookup(root_volume_configuration.value, "record_size_kib", null)

#       dynamic "nfs_exports" {
#         for_each = lookup(root_volume_configuration.value, "nfs_exports", [])
#         content {
#           dynamic "client_configurations" {
#             for_each = nfs_exports.value.client_configurations
#             content {
#               clients = client_configurations.value.clients
#               options = client_configurations.value.options
#             }
#           }
#         }
#       }

#       dynamic "user_and_group_quotas" {
#         for_each = lookup(root_volume_configuration.value, "user_and_group_quotas", [])
#         content {
#           id                         = user_and_group_quotas.value.id
#           storage_capacity_quota_gib = user_and_group_quotas.value.storage_capacity_quota_gib
#           type                       = user_and_group_quotas.value.type
#         }
#       }
#     }
#   }

#   automatic_backup_retention_days   = var.automatic_backup_retention_days
#   daily_automatic_backup_start_time = var.daily_automatic_backup_start_time
#   weekly_maintenance_start_time     = var.weekly_maintenance_start_time
#   security_group_ids                = local.security_group_ids

#   tags = local.tags
# }

resource "aws_fsx_openzfs_file_system" "this" {
  count = var.create && var.fsx_type == "openzfs" ? 1 : 0

  storage_capacity     = var.storage_capacity
  subnet_ids           = var.subnet_ids
  deployment_type      = var.deployment_type
  throughput_capacity  = var.throughput_capacity
  storage_type         = var.storage_type
  kms_key_id           = var.kms_key_id
  copy_tags_to_backups = var.copy_tags_to_backups
  skip_final_backup    = var.skip_final_backup
  final_backup_tags    = var.final_backup_tags

  dynamic "disk_iops_configuration" {
    for_each = var.disk_iops_configuration != null ? [var.disk_iops_configuration] : []
    content {
      mode = disk_iops_configuration.value.mode
      iops = try(disk_iops_configuration.value.iops, null)
    }
  }

  # dynamic "root_volume_configuration" {
  #   for_each = var.root_volume_configuration != null ? [var.root_volume_configuration] : []
  #   content {
  #     copy_tags_to_snapshots = try(root_volume_configuration.value.copy_tags_to_snapshots, null)
  #     data_compression_type  = try(root_volume_configuration.value.data_compression_type, null)
  #     read_only              = try(root_volume_configuration.value.read_only, null)
  #     record_size_kib        = try(root_volume_configuration.value.record_size_kib, null)

  #     # -------------------------
  #     # NFS EXPORTS
  #     # -------------------------
  #     dynamic "nfs_exports" {
  #       for_each = try(root_volume_configuration.value.nfs_exports, [])
  #       content {
  #         dynamic "client_configurations" {
  #           for_each = nfs_exports.value.client_configurations
  #           content {
  #             clients = client_configurations.value.clients
  #             options = client_configurations.value.options
  #           }
  #         }
  #       }
  #     }

  #     # -------------------------
  #     # USER & GROUP QUOTAS
  #     # -------------------------
  #     dynamic "user_and_group_quotas" {
  #       for_each = try(root_volume_configuration.value.user_and_group_quotas, [])
  #       content {
  #         id                         = user_and_group_quotas.value.id
  #         storage_capacity_quota_gib = user_and_group_quotas.value.storage_capacity_quota_gib
  #         type                       = user_and_group_quotas.value.type
  #       }
  #     }
  #   }
  # }
  dynamic "root_volume_configuration" {
    for_each = var.root_volume_configuration != null ? [var.root_volume_configuration] : []
    content {
      copy_tags_to_snapshots = try(root_volume_configuration.value.copy_tags_to_snapshots, null)
      data_compression_type  = try(root_volume_configuration.value.data_compression_type, null)
      read_only              = try(root_volume_configuration.value.read_only, null)
      record_size_kib        = try(root_volume_configuration.value.record_size_kib, null)

      dynamic "nfs_exports" {
        for_each = (
          try(root_volume_configuration.value.nfs_exports, null) != null
          ? root_volume_configuration.value.nfs_exports
          : []
        )
        content {
          dynamic "client_configurations" {
            for_each = nfs_exports.value.client_configurations
            content {
              clients = client_configurations.value.clients
              options = client_configurations.value.options
            }
          }
        }
      }

      dynamic "user_and_group_quotas" {
        for_each = (
          try(root_volume_configuration.value.user_and_group_quotas, null) != null
          ? root_volume_configuration.value.user_and_group_quotas
          : []
        )
        content {
          id                         = user_and_group_quotas.value.id
          storage_capacity_quota_gib = user_and_group_quotas.value.storage_capacity_quota_gib
          type                       = user_and_group_quotas.value.type
        }
      }
    }
  }

  automatic_backup_retention_days   = var.automatic_backup_retention_days
  daily_automatic_backup_start_time = var.daily_automatic_backup_start_time
  weekly_maintenance_start_time     = var.weekly_maintenance_start_time
  security_group_ids                = local.security_group_ids

  tags = local.tags
}

################################################################################
# Data Repository Association (Lustre only)
################################################################################

resource "aws_fsx_data_repository_association" "this" {
  for_each = var.create && var.fsx_type == "lustre" ? var.data_repository_associations : {}

  file_system_id                   = aws_fsx_lustre_file_system.this[0].id
  data_repository_path             = each.value.data_repository_path
  file_system_path                 = each.value.file_system_path
  batch_import_meta_data_on_create = lookup(each.value, "batch_import_meta_data_on_create", null)
  imported_file_chunk_size         = lookup(each.value, "imported_file_chunk_size", null)

  dynamic "s3" {
    for_each = lookup(each.value, "s3", null) != null ? [each.value.s3] : []
    content {
      auto_export_policy {
        events = s3.value.auto_export_policy.events
      }
      auto_import_policy {
        events = s3.value.auto_import_policy.events
      }
    }
  }

  tags = local.tags

  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}

################################################################################
# IAM Role for FSx
################################################################################

resource "aws_iam_role" "this" {
  count = var.create && var.create_iam_role ? 1 : 0

  name_prefix        = "${local.name_prefix}-fsx-"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  tags               = local.tags
}

data "aws_iam_policy_document" "assume_role" {
  count = var.create && var.create_iam_role ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["fsx.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.create && var.create_iam_role ? toset(var.iam_policy_arns) : []

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "custom" {
  count = var.create && var.create_iam_role && var.custom_iam_policy != null ? 1 : 0

  name_prefix = "${local.name_prefix}-fsx-custom-"
  role        = aws_iam_role.this[0].id
  policy      = var.custom_iam_policy
}

################################################################################
# FSx File Cache
################################################################################

resource "aws_fsx_file_cache" "this" {
  count = var.create && var.create_file_cache ? 1 : 0

  file_cache_type                           = var.file_cache_type
  file_cache_type_version                   = var.file_cache_type_version
  storage_capacity                          = var.file_cache_storage_capacity
  subnet_ids                                = var.subnet_ids
  kms_key_id                                = var.kms_key_id
  copy_tags_to_data_repository_associations = var.copy_tags_to_data_repository_associations

  dynamic "lustre_configuration" {
    for_each = var.file_cache_lustre_configuration != null ? [var.file_cache_lustre_configuration] : []
    content {
      deployment_type               = lustre_configuration.value.deployment_type
      per_unit_storage_throughput   = lustre_configuration.value.per_unit_storage_throughput
      weekly_maintenance_start_time = lookup(lustre_configuration.value, "weekly_maintenance_start_time", null)

      dynamic "metadata_configuration" {
        for_each = lookup(lustre_configuration.value, "metadata_configuration", null) != null ? [lustre_configuration.value.metadata_configuration] : []
        content {
          storage_capacity = metadata_configuration.value.storage_capacity
        }
      }
    }
  }

  security_group_ids = local.security_group_ids
  tags               = local.tags
}

################################################################################
# ONTAP Storage Virtual Machine
################################################################################
resource "random_password" "svm_admin" {
  for_each = {
    for k, v in var.ontap_storage_virtual_machines :
    k => v
    if lookup(v, "svm_admin_password", null) == null
  }

  length  = 24
  special = true
}

resource "aws_ssm_parameter" "svm_admin" {
  for_each = random_password.svm_admin

  name  = "/fsx/ontap/${var.environment}/svm/${each.key}/admin-${random_id.fsx.hex}"
  type  = "SecureString"
  value = each.value.result

  tags = local.tags
}


resource "aws_fsx_ontap_storage_virtual_machine" "this" {
  for_each = var.create && var.fsx_type == "ontap" ? var.ontap_storage_virtual_machines : {}

  file_system_id = aws_fsx_ontap_file_system.this[0].id
  name           = each.value.name
  # svm_admin_password         = lookup(each.value, "svm_admin_password", null)
  svm_admin_password         = coalesce(lookup(each.value, "svm_admin_password", null), try(random_password.svm_admin[each.key].result, null))
  root_volume_security_style = lookup(each.value, "root_volume_security_style", "UNIX")

  dynamic "active_directory_configuration" {
    for_each = lookup(each.value, "active_directory_configuration", null) != null ? [each.value.active_directory_configuration] : []
    content {
      netbios_name = active_directory_configuration.value.netbios_name
      self_managed_active_directory_configuration {
        dns_ips                                = active_directory_configuration.value.dns_ips
        domain_name                            = active_directory_configuration.value.domain_name
        password                               = active_directory_configuration.value.password
        username                               = active_directory_configuration.value.username
        file_system_administrators_group       = lookup(active_directory_configuration.value, "file_system_administrators_group", null)
        organizational_unit_distinguished_name = lookup(active_directory_configuration.value, "organizational_unit_distinguished_name", null)
      }
    }
  }

  tags = local.tags
}

################################################################################
# ONTAP Volume
################################################################################

# resource "aws_fsx_ontap_volume" "this" {
#   for_each = var.create && var.fsx_type == "ontap" ? var.ontap_volumes : {}

#   name                       = each.value.name
#   storage_virtual_machine_id = aws_fsx_ontap_storage_virtual_machine.this[each.value.svm_name].id
#   size_in_megabytes          = each.value.size_in_megabytes
#   storage_efficiency_enabled = lookup(each.value, "storage_efficiency_enabled", true)
#   junction_path              = lookup(each.value, "junction_path", null)
#   security_style             = lookup(each.value, "security_style", "UNIX")
#   volume_type                = lookup(each.value, "volume_type", "RW")
#   ontap_volume_type          = lookup(each.value, "ontap_volume_type", "RW")
#   copy_tags_to_backups       = lookup(each.value, "copy_tags_to_backups", false)
#   skip_final_backup          = lookup(each.value, "skip_final_backup", false)
#   final_backup_tags          = lookup(each.value, "final_backup_tags", {})

#   dynamic "tiering_policy" {
#     for_each = lookup(each.value, "tiering_policy", null) != null ? [each.value.tiering_policy] : []
#     content {
#       cooling_period = lookup(tiering_policy.value, "cooling_period", null)
#       name           = lookup(tiering_policy.value, "name", "SNAPSHOT_ONLY")
#     }
#   }

#   tags = local.tags
# }

resource "aws_fsx_ontap_volume" "this" {
  for_each = var.create && var.fsx_type == "ontap" ? var.ontap_volumes : {}

  # ---------------------------------------------------------------------------
  # Required
  # ---------------------------------------------------------------------------
  name = replace(each.value.name, "-", "_")

  storage_virtual_machine_id = aws_fsx_ontap_storage_virtual_machine.this[
    each.value.svm_name
  ].id

  # ---------------------------------------------------------------------------
  # Size (one of these is required by AWS)
  # ---------------------------------------------------------------------------
  size_in_megabytes = lookup(each.value, "size_in_megabytes", null)
  size_in_bytes     = lookup(each.value, "size_in_bytes", null)

  # ---------------------------------------------------------------------------
  # REQUIRED for ONTAP (no default in AWS API)
  # ---------------------------------------------------------------------------
  storage_efficiency_enabled = lookup(
    each.value,
    "storage_efficiency_enabled",
    true
  )

  # ---------------------------------------------------------------------------
  # Optional top-level attributes
  # ---------------------------------------------------------------------------
  junction_path        = lookup(each.value, "junction_path", null)
  security_style       = lookup(each.value, "security_style", null)
  volume_style         = lookup(each.value, "volume_style", "FLEXVOL")
  ontap_volume_type    = lookup(each.value, "ontap_volume_type", "RW")
  snapshot_policy      = lookup(each.value, "snapshot_policy", null)
  copy_tags_to_backups = lookup(each.value, "copy_tags_to_backups", false)
  skip_final_backup    = lookup(each.value, "skip_final_backup", false)
  final_backup_tags    = lookup(each.value, "final_backup_tags", {})
  bypass_snaplock_enterprise_retention = lookup(
    each.value,
    "bypass_snaplock_enterprise_retention",
    false
  )

  # ---------------------------------------------------------------------------
  # Aggregate Configuration (FLEXGROUP only)
  # ---------------------------------------------------------------------------
  dynamic "aggregate_configuration" {
    for_each = lookup(each.value, "aggregate_configuration", null) != null ? [each.value.aggregate_configuration] : []

    content {
      aggregates = lookup(aggregate_configuration.value, "aggregates", null)
      constituents_per_aggregate = lookup(
        aggregate_configuration.value,
        "constituents_per_aggregate",
        8
      )
    }
  }

  # ---------------------------------------------------------------------------
  # SnapLock Configuration
  # ---------------------------------------------------------------------------
  dynamic "snaplock_configuration" {
    for_each = lookup(each.value, "snaplock_configuration", null) != null ? [each.value.snaplock_configuration] : []

    content {
      snaplock_type    = snaplock_configuration.value.snaplock_type
      audit_log_volume = lookup(snaplock_configuration.value, "audit_log_volume", false)
      privileged_delete = lookup(
        snaplock_configuration.value,
        "privileged_delete",
        "DISABLED"
      )
      volume_append_mode_enabled = lookup(
        snaplock_configuration.value,
        "volume_append_mode_enabled",
        false
      )

      dynamic "autocommit_period" {
        for_each = lookup(snaplock_configuration.value, "autocommit_period", null) != null ? [snaplock_configuration.value.autocommit_period] : []

        content {
          type  = autocommit_period.value.type
          value = lookup(autocommit_period.value, "value", null)
        }
      }

      dynamic "retention_period" {
        for_each = lookup(snaplock_configuration.value, "retention_period", null) != null ? [snaplock_configuration.value.retention_period] : []

        content {
          dynamic "default_retention" {
            for_each = [retention_period.value.default_retention]
            content {
              type  = default_retention.value.type
              value = lookup(default_retention.value, "value", null)
            }
          }

          dynamic "maximum_retention" {
            for_each = [retention_period.value.maximum_retention]
            content {
              type  = maximum_retention.value.type
              value = lookup(maximum_retention.value, "value", null)
            }
          }

          dynamic "minimum_retention" {
            for_each = [retention_period.value.minimum_retention]
            content {
              type  = minimum_retention.value.type
              value = lookup(minimum_retention.value, "value", null)
            }
          }
        }
      }
    }
  }

  # ---------------------------------------------------------------------------
  # Tiering Policy
  # ---------------------------------------------------------------------------
  dynamic "tiering_policy" {
    for_each = lookup(each.value, "tiering_policy", null) != null ? [each.value.tiering_policy] : []

    content {
      name           = lookup(tiering_policy.value, "name", "SNAPSHOT_ONLY")
      cooling_period = lookup(tiering_policy.value, "cooling_period", null)
    }
  }


  # ---------------------------------------------------------------------------
  # Tags (sanitized for FSx + SSM)
  # ---------------------------------------------------------------------------
  tags = local.tags
}


################################################################################
# OpenZFS Volume
################################################################################

# resource "aws_fsx_openzfs_volume" "this" {
#   for_each = var.create && var.fsx_type == "openzfs" ? var.openzfs_volumes : {}

#   name                             = each.value.name
#   parent_volume_id                 = lookup(each.value, "parent_volume_id", aws_fsx_openzfs_file_system.this[0].root_volume_id)
#   storage_capacity_quota_gib       = lookup(each.value, "storage_capacity_quota_gib", null)
#   storage_capacity_reservation_gib = lookup(each.value, "storage_capacity_reservation_gib", null)
#   copy_tags_to_snapshots           = lookup(each.value, "copy_tags_to_snapshots", false)
#   data_compression_type            = lookup(each.value, "data_compression_type", "NONE")
#   read_only                        = lookup(each.value, "read_only", false)
#   record_size_kib                  = lookup(each.value, "record_size_kib", 128)

#   dynamic "nfs_exports" {
#     for_each = lookup(each.value, "nfs_exports", [])
#     content {
#       dynamic "client_configurations" {
#         for_each = nfs_exports.value.client_configurations
#         content {
#           clients = client_configurations.value.clients
#           options = client_configurations.value.options
#         }
#       }
#     }
#   }

#   # dynamic "user_and_group_quotas" {
#   #   for_each = lookup(each.value, "user_and_group_quotas", [])
#   #   content {
#   #     id                         = user_and_group_quotas.value.id
#   #     storage_capacity_quota_gib = user_and_group_quotas.value.storage_capacity_quota_gib
#   #     type                       = user_and_group_quotas.value.type
#   #   }
#   # }
#   dynamic "user_and_group_quotas" {
#     for_each = try(each.value.user_and_group_quotas, [])
#     content {
#       id                         = user_and_group_quotas.value.id
#       storage_capacity_quota_gib = user_and_group_quotas.value.storage_capacity_quota_gib
#       type                       = user_and_group_quotas.value.type
#     }
#   }

#   tags = local.tags
# }

resource "aws_fsx_openzfs_volume" "this" {
  for_each = var.create && var.fsx_type == "openzfs" ? var.openzfs_volumes : {}

  name = each.value.name
  # parent_volume_id = try(each.value.parent_volume_id, aws_fsx_openzfs_file_system.this[0].root_volume_id)
  parent_volume_id = coalesce(try(each.value.parent_volume_id, null), try(aws_fsx_openzfs_file_system.this[0].root_volume_id, null))


  copy_tags_to_snapshots = try(each.value.copy_tags_to_snapshots, false)
  data_compression_type  = try(each.value.data_compression_type, null)
  read_only              = try(each.value.read_only, false)
  record_size_kib        = try(each.value.record_size_kib, 128)

  storage_capacity_quota_gib       = try(each.value.storage_capacity_quota_gib, null)
  storage_capacity_reservation_gib = try(each.value.storage_capacity_reservation_gib, null)

  delete_volume_options = try(each.value.delete_volume_options, [])

  # --------------------------
  # NFS EXPORTS
  # --------------------------
  dynamic "nfs_exports" {
    for_each = try(each.value.nfs_exports, [])
    content {
      dynamic "client_configurations" {
        for_each = nfs_exports.value.client_configurations
        content {
          clients = client_configurations.value.clients
          options = client_configurations.value.options
        }
      }
    }
  }

  # --------------------------
  # ORIGIN SNAPSHOT
  # --------------------------
  dynamic "origin_snapshot" {
    for_each = each.value.origin_snapshot != null ? [each.value.origin_snapshot] : []
    content {
      copy_strategy = origin_snapshot.value.copy_strategy
      snapshot_arn  = origin_snapshot.value.snapshot_arn
    }
  }

  # --------------------------
  # USER & GROUP QUOTAS
  # --------------------------
  dynamic "user_and_group_quotas" {
    for_each = try(each.value.user_and_group_quotas, [])
    content {
      id                         = user_and_group_quotas.value.id
      storage_capacity_quota_gib = user_and_group_quotas.value.storage_capacity_quota_gib
      type                       = user_and_group_quotas.value.type
    }
  }

  tags = merge(
    local.tags,
    try(each.value.tags, {})
  )
}

################################################################################
# OpenZFS Snapshot
################################################################################

resource "aws_fsx_openzfs_snapshot" "this" {
  for_each = var.create && var.fsx_type == "openzfs" ? var.openzfs_snapshots : {}

  name      = each.value.name
  volume_id = aws_fsx_openzfs_volume.this[each.value.volume_name].id

  tags = local.tags
}

################################################################################
# FSx Backup
################################################################################

# resource "aws_fsx_backup" "this" {
#   for_each = var.create ? var.fsx_backups : {}

#   file_system_id = local.fsx_id
#   volume_id      = lookup(each.value, "volume_id", null)

#   tags = merge(local.tags, {
#     Name = "${local.name_prefix}-backup-${each.key}"
#   })
# }


resource "aws_fsx_backup" "this" {
  for_each = var.create && var.fsx_type != "ontap" ? var.fsx_backups : {}

  file_system_id = local.fsx_id

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-backup-${each.key}"
  })
}