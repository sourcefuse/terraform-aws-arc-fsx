locals {
  name_prefix = var.name != "" ? var.name : "fsx"

  # Merge default and custom tags
  tags = merge(
    {
      Name        = local.name_prefix
      Environment = var.environment
      ManagedBy   = "terraform"
      FSxType     = var.fsx_type
    },
    var.tags
  )

  # FSx ID helper for backups
  fsx_id = var.fsx_type == "windows" ? (
    length(aws_fsx_windows_file_system.this) > 0 ? aws_fsx_windows_file_system.this[0].id : null
    ) : var.fsx_type == "lustre" ? (
    length(aws_fsx_lustre_file_system.this) > 0 ? aws_fsx_lustre_file_system.this[0].id : null
    ) : var.fsx_type == "ontap" ? (
    length(aws_fsx_ontap_file_system.this) > 0 ? aws_fsx_ontap_file_system.this[0].id : null
    ) : var.fsx_type == "openzfs" ? (
    length(aws_fsx_openzfs_file_system.this) > 0 ? aws_fsx_openzfs_file_system.this[0].id : null
  ) : null

  # Security group IDs - use provided
  security_group_ids = var.security_group_ids
}


# locals {
#   is_lustre_s3_linked = (
#     var.fsx_type == "lustre" &&
#     (
#       var.import_path != null ||
#       var.export_path != null ||
#       length(var.data_repository_associations) > 0
#     )
#   )
# }

locals {
  is_lustre       = var.fsx_type == "lustre"
  is_persistent_2 = local.is_lustre && var.deployment_type == "PERSISTENT_2"

  is_lustre_s3_linked = local.is_lustre && (
    var.import_path != null ||
    var.export_path != null ||
    length(var.data_repository_associations) > 0
  )

  enable_lustre_config_at_create = local.is_lustre && !local.is_persistent_2
}

