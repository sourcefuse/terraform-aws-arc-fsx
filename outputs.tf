################################################################################
# FSx File System Outputs
################################################################################

output "fsx_id" {
  description = "ID of the FSx file system"
  value = var.fsx_type == "windows" ? (
    length(aws_fsx_windows_file_system.this) > 0 ? aws_fsx_windows_file_system.this[0].id : null
    ) : var.fsx_type == "lustre" ? (
    length(aws_fsx_lustre_file_system.this) > 0 ? aws_fsx_lustre_file_system.this[0].id : null
    ) : var.fsx_type == "ontap" ? (
    length(aws_fsx_ontap_file_system.this) > 0 ? aws_fsx_ontap_file_system.this[0].id : null
    ) : var.fsx_type == "openzfs" ? (
    length(aws_fsx_openzfs_file_system.this) > 0 ? aws_fsx_openzfs_file_system.this[0].id : null
  ) : null
}

output "fsx_arn" {
  description = "ARN of the FSx file system"
  value = var.fsx_type == "windows" ? (
    length(aws_fsx_windows_file_system.this) > 0 ? aws_fsx_windows_file_system.this[0].arn : null
    ) : var.fsx_type == "lustre" ? (
    length(aws_fsx_lustre_file_system.this) > 0 ? aws_fsx_lustre_file_system.this[0].arn : null
    ) : var.fsx_type == "ontap" ? (
    length(aws_fsx_ontap_file_system.this) > 0 ? aws_fsx_ontap_file_system.this[0].arn : null
    ) : var.fsx_type == "openzfs" ? (
    length(aws_fsx_openzfs_file_system.this) > 0 ? aws_fsx_openzfs_file_system.this[0].arn : null
  ) : null
}

output "fsx_dns_name" {
  description = "DNS name of the FSx file system"
  value = var.fsx_type == "windows" ? (
    length(aws_fsx_windows_file_system.this) > 0 ? aws_fsx_windows_file_system.this[0].dns_name : null
    ) : var.fsx_type == "lustre" ? (
    length(aws_fsx_lustre_file_system.this) > 0 ? aws_fsx_lustre_file_system.this[0].dns_name : null
    ) : var.fsx_type == "ontap" ? (
    length(aws_fsx_ontap_file_system.this) > 0 ? aws_fsx_ontap_file_system.this[0].dns_name : null
    ) : var.fsx_type == "openzfs" ? (
    length(aws_fsx_openzfs_file_system.this) > 0 ? aws_fsx_openzfs_file_system.this[0].dns_name : null
  ) : null
}

output "fsx_network_interface_ids" {
  description = "Network interface IDs of the FSx file system"
  value = var.fsx_type == "windows" ? (
    length(aws_fsx_windows_file_system.this) > 0 ? aws_fsx_windows_file_system.this[0].network_interface_ids : []
    ) : var.fsx_type == "lustre" ? (
    length(aws_fsx_lustre_file_system.this) > 0 ? aws_fsx_lustre_file_system.this[0].network_interface_ids : []
    ) : var.fsx_type == "ontap" ? (
    length(aws_fsx_ontap_file_system.this) > 0 ? aws_fsx_ontap_file_system.this[0].network_interface_ids : []
    ) : var.fsx_type == "openzfs" ? (
    length(aws_fsx_openzfs_file_system.this) > 0 ? aws_fsx_openzfs_file_system.this[0].network_interface_ids : []
  ) : []
}

output "fsx_owner_id" {
  description = "AWS account ID of the FSx file system owner"
  value = var.fsx_type == "windows" ? (
    length(aws_fsx_windows_file_system.this) > 0 ? aws_fsx_windows_file_system.this[0].owner_id : null
    ) : var.fsx_type == "lustre" ? (
    length(aws_fsx_lustre_file_system.this) > 0 ? aws_fsx_lustre_file_system.this[0].owner_id : null
    ) : var.fsx_type == "ontap" ? (
    length(aws_fsx_ontap_file_system.this) > 0 ? aws_fsx_ontap_file_system.this[0].owner_id : null
    ) : var.fsx_type == "openzfs" ? (
    length(aws_fsx_openzfs_file_system.this) > 0 ? aws_fsx_openzfs_file_system.this[0].owner_id : null
  ) : null
}

################################################################################
# FSx Type-Specific Outputs
################################################################################

# Windows File Server
output "windows_remote_administration_endpoint" {
  description = "Remote administration endpoint for Windows file system"
  value = var.fsx_type == "windows" && length(aws_fsx_windows_file_system.this) > 0 ? (
    aws_fsx_windows_file_system.this[0].remote_administration_endpoint
  ) : null
}

# Lustre
output "lustre_mount_name" {
  description = "Mount name for Lustre file system"
  value = var.fsx_type == "lustre" && length(aws_fsx_lustre_file_system.this) > 0 ? (
    aws_fsx_lustre_file_system.this[0].mount_name
  ) : null
}

# ONTAP
output "ontap_endpoints" {
  description = "ONTAP file system endpoints"
  value = var.fsx_type == "ontap" && length(aws_fsx_ontap_file_system.this) > 0 ? (
    aws_fsx_ontap_file_system.this[0].endpoints
  ) : null
}

# OpenZFS
output "openzfs_root_volume_id" {
  description = "Root volume ID for OpenZFS file system"
  value = var.fsx_type == "openzfs" && length(aws_fsx_openzfs_file_system.this) > 0 ? (
    aws_fsx_openzfs_file_system.this[0].root_volume_id
  ) : null
}


################################################################################
# IAM Outputs
################################################################################

output "iam_role_arn" {
  description = "ARN of the created IAM role"
  value       = local.iam_config.create_iam_role && length(aws_iam_role.this) > 0 ? aws_iam_role.this[0].arn : null
}

output "iam_role_name" {
  description = "Name of the created IAM role"
  value       = local.iam_config.create_iam_role && length(aws_iam_role.this) > 0 ? aws_iam_role.this[0].name : null
}

################################################################################
# Data Repository Association Outputs
################################################################################

output "data_repository_association_ids" {
  description = "IDs of the data repository associations"
  value       = { for k, v in aws_fsx_data_repository_association.this : k => v.id }
}

################################################################################
# General Outputs
################################################################################

output "fsx_type" {
  description = "Type of FSx file system created"
  value       = var.fsx_type
}

output "tags" {
  description = "Tags applied to the FSx file system"
  value       = local.tags
}

################################################################################
# File Cache Outputs
################################################################################

output "file_cache_id" {
  description = "ID of the FSx File Cache"
  value       = local.file_cache_config.create_file_cache && length(aws_fsx_file_cache.this) > 0 ? aws_fsx_file_cache.this[0].id : null
}

output "file_cache_dns_name" {
  description = "DNS name of the FSx File Cache"
  value       = local.file_cache_config.create_file_cache && length(aws_fsx_file_cache.this) > 0 ? aws_fsx_file_cache.this[0].dns_name : null
}

output "file_cache_network_interface_ids" {
  description = "Network interface IDs of the FSx File Cache"
  value       = local.file_cache_config.create_file_cache && length(aws_fsx_file_cache.this) > 0 ? aws_fsx_file_cache.this[0].network_interface_ids : []
}

################################################################################
# ONTAP SVM Outputs
################################################################################

output "ontap_storage_virtual_machine_ids" {
  description = "IDs of ONTAP Storage Virtual Machines"
  value       = { for k, v in aws_fsx_ontap_storage_virtual_machine.this : k => v.id }
}

output "ontap_storage_virtual_machine_endpoints" {
  description = "Endpoints of ONTAP Storage Virtual Machines"
  value       = { for k, v in aws_fsx_ontap_storage_virtual_machine.this : k => v.endpoints }
}

################################################################################
# ONTAP Volume Outputs
################################################################################

output "ontap_volume_ids" {
  description = "IDs of ONTAP Volumes"
  value       = { for k, v in aws_fsx_ontap_volume.this : k => v.id }
}

output "ontap_volume_arns" {
  description = "ARNs of ONTAP Volumes"
  value       = { for k, v in aws_fsx_ontap_volume.this : k => v.arn }
}

################################################################################
# OpenZFS Volume Outputs
################################################################################

output "openzfs_volume_ids" {
  description = "IDs of OpenZFS Volumes"
  value       = { for k, v in aws_fsx_openzfs_volume.this : k => v.id }
}

output "openzfs_volume_arns" {
  description = "ARNs of OpenZFS Volumes"
  value       = { for k, v in aws_fsx_openzfs_volume.this : k => v.arn }
}

################################################################################
# OpenZFS Snapshot Outputs
################################################################################

output "openzfs_snapshot_ids" {
  description = "IDs of OpenZFS Snapshots"
  value       = { for k, v in aws_fsx_openzfs_snapshot.this : k => v.id }
}

output "openzfs_snapshot_arns" {
  description = "ARNs of OpenZFS Snapshots"
  value       = { for k, v in aws_fsx_openzfs_snapshot.this : k => v.arn }
}

################################################################################
# Backup Outputs
################################################################################

output "fsx_backup_ids" {
  description = "IDs of FSx Backups"
  value       = { for k, v in aws_fsx_backup.this : k => v.id }
}

output "fsx_backup_arns" {
  description = "ARNs of FSx Backups"
  value       = { for k, v in aws_fsx_backup.this : k => v.arn }
}
