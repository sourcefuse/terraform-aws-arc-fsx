# Basic Windows File Server Example
This example demonstrates how to create a basic FSx for Windows File Server with AWS Managed Microsoft Active Directory integration.

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

1. Configure Variables `terraform.tfvars`
2. Update the values with your actual resources
3. Run Terraform:

```bash
terraform init
terraform plan
terraform apply
```
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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fsx_windows"></a> [fsx\_windows](#module\_fsx\_windows) | ../.. | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | sourcefuse/arc-security-group/aws | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

| Name | Type |
|------|------|
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_active_directory_id"></a> [active\_directory\_id](#input\_active\_directory\_id) | AWS Managed Microsoft AD ID | `string` | n/a | yes |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDR blocks allowed to access FSx | `list(string)` | <pre>[<br/>  "10.0.0.0/8"<br/>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment, i.e. dev, stage, prod | `string` | `"poc"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of the project, i.e. arc | `string` | `"arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fsx_dns_name"></a> [fsx\_dns\_name](#output\_fsx\_dns\_name) | FSx DNS name for mounting |
| <a name="output_fsx_id"></a> [fsx\_id](#output\_fsx\_id) | FSx file system ID |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID created for FSx |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
