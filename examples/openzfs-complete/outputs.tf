output "fsx_id" {
  description = "FSx file system ID"
  value       = module.fsx_openzfs_complete.fsx_id
}

output "fsx_dns_name" {
  description = "FSx DNS name"
  value       = module.fsx_openzfs_complete.fsx_dns_name
}

output "root_volume_id" {
  description = "Root volume ID"
  value       = module.fsx_openzfs_complete.openzfs_root_volume_id
}

output "volume_ids" {
  description = "OpenZFS Volume IDs"
  value       = module.fsx_openzfs_complete.openzfs_volume_ids
}

output "snapshot_ids" {
  description = "OpenZFS Snapshot IDs"
  value       = module.fsx_openzfs_complete.openzfs_snapshot_ids
}

output "backup_ids" {
  description = "FSx Backup IDs"
  value       = module.fsx_openzfs_complete.fsx_backup_ids
}
