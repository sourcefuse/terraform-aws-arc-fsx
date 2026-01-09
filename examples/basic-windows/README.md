# Basic Windows File Server Example

This example demonstrates how to create a basic FSx for Windows File Server with AWS Managed Microsoft Active Directory integration.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      VPC        │    │  AWS Managed AD │    │ FSx Windows FS  │
│                 │    │                 │    │                 │
│  Private Subnet │────│   Domain Join   │────│   Single-AZ     │
└─────────────────┘    └─────────────────┘    │   32 GiB SSD    │
                                              └─────────────────┘
```

## Features

- Single-AZ deployment for cost optimization
- AWS Managed Microsoft AD integration
- Automatic security group with SMB/CIFS access
- Daily backups with 7-day retention
- Weekly maintenance window

## Prerequisites

- VPC with private subnet
- AWS Managed Microsoft Active Directory
- Appropriate IAM permissions for FSx

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars`
2. Update the values with your actual resources
3. Run Terraform:

```bash
terraform init
terraform plan
terraform apply
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| vpc_id | VPC ID where FSx will be deployed | `string` | yes |
| subnet_ids | List of subnet IDs for FSx deployment | `list(string)` | yes |
| active_directory_id | AWS Managed Microsoft AD ID | `string` | yes |
| allowed_cidr_blocks | CIDR blocks allowed to access FSx | `list(string)` | no |

## Outputs

| Name | Description |
|------|-------------|
| fsx_id | FSx file system ID |
| fsx_dns_name | FSx DNS name for mounting |
| security_group_id | Security group ID created for FSx |

## Mounting the File System

Once deployed, you can mount the file system on Windows clients:

```cmd
net use Z: \\fsx-dns-name\share
```

## Clean Up

```bash
terraform destroy
```

## Cost Considerations

- Single-AZ deployment reduces costs compared to Multi-AZ
- 32 GiB is the minimum storage capacity
- Consider throughput capacity based on your workload requirements
