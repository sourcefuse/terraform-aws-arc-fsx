################################################################################
## shared
################################################################################
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  type        = string
  description = "Name of the environment, i.e. dev, stage, prod"
  default     = "poc"
}

variable "namespace" {
  type        = string
  default     = "arc"
  description = "Namespace of the project, i.e. arc"
}


variable "ad_dns_ips" {
  description = "DNS IP addresses for self-managed Active Directory"
  type        = list(string)
}

variable "ad_domain_name" {
  description = "Domain name for self-managed Active Directory"
  type        = string
}

variable "ad_password" {
  description = "Password for AD service account"
  type        = string
  sensitive   = true
}

variable "ad_username" {
  description = "Username for AD service account"
  type        = string
}

variable "ad_admin_group" {
  description = "AD group for file system administrators"
  type        = string
  default     = "Domain Admins"
}

variable "ad_ou_dn" {
  description = "Organizational Unit Distinguished Name"
  type        = string
  default     = null
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access FSx"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}
