output "fsx_id" {
  description = "FSx file system ID"
  value       = module.fsx_ontap.fsx_id
}

output "fsx_dns_name" {
  description = "FSx DNS name"
  value       = module.fsx_ontap.fsx_dns_name
}

output "ontap_endpoints" {
  description = "ONTAP endpoints"
  value       = module.fsx_ontap.ontap_endpoints
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.security_group.id
}
