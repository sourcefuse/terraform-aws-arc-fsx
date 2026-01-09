output "fsx_id" {
  description = "FSx file system ID"
  value       = module.fsx_windows_self_managed.fsx_id
}

output "fsx_dns_name" {
  description = "FSx DNS name for mounting"
  value       = module.fsx_windows_self_managed.fsx_dns_name
}

output "remote_administration_endpoint" {
  description = "Remote administration endpoint"
  value       = module.fsx_windows_self_managed.windows_remote_administration_endpoint
}

output "security_group_id" {
  description = "Security group ID created for FSx"
  value       = module.security_group.id
}
