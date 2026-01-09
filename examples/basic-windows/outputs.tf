output "fsx_id" {
  description = "FSx file system ID"
  value       = module.fsx_windows.fsx_id
}

output "fsx_dns_name" {
  description = "FSx DNS name for mounting"
  value       = module.fsx_windows.fsx_dns_name
}

output "security_group_id" {
  description = "Security group ID created for FSx"
  value       = module.security_group.id
}
