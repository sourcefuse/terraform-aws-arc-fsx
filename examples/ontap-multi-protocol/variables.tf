################################################################################
## shared
################################################################################
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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

# variable "vpc_id" {
#   description = "VPC ID where FSx will be deployed"
#   type        = string
# }

# variable "subnet_ids" {
#   description = "List of subnet IDs for FSx deployment"
#   type        = list(string)
# }

# variable "preferred_subnet_id" {
#   description = "Preferred subnet ID for multi-AZ deployment"
#   type        = string
# }

# variable "fsx_admin_password" {
#   description = "FSx admin password for ONTAP"
#   type        = string
#   sensitive   = true
# }

# variable "allowed_cidr_blocks" {
#   description = "CIDR blocks allowed to access FSx"
#   type        = list(string)
#   default     = ["10.0.0.0/8"]
# }