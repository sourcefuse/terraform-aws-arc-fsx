output "fsx_id" {
  description = "FSx file system ID"
  value       = module.fsx_lustre.fsx_id
}

output "fsx_dns_name" {
  description = "FSx DNS name for mounting"
  value       = module.fsx_lustre.fsx_dns_name
}

output "lustre_mount_name" {
  description = "Lustre mount name"
  value       = module.fsx_lustre.lustre_mount_name
}

output "data_repository_association_ids" {
  description = "Data repository association IDs"
  value       = module.fsx_lustre.data_repository_association_ids
}
