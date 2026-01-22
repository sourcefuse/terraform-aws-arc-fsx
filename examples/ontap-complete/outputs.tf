output "fsx_id" {
  description = "FSx file system ID"
  value       = module.fsx_ontap_complete.fsx_id
}

output "ontap_endpoints" {
  description = "ONTAP endpoints"
  value       = module.fsx_ontap_complete.ontap_endpoints
}

output "svm_ids" {
  description = "Storage Virtual Machine IDs"
  value       = module.fsx_ontap_complete.ontap_storage_virtual_machine_ids
}

output "volume_ids" {
  description = "ONTAP Volume IDs"
  value       = module.fsx_ontap_complete.ontap_volume_ids
}

output "backup_ids" {
  description = "FSx Backup IDs"
  value       = module.fsx_ontap_complete.fsx_backup_ids
}
