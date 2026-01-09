<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fsx_windows_self_managed"></a> [fsx\_windows\_self\_managed](#module\_fsx\_windows\_self\_managed) | ../.. | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | sourcefuse/arc-security-group/aws | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.ad_join](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.ad_join](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.ascend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ad_admin_group"></a> [ad\_admin\_group](#input\_ad\_admin\_group) | AD group for file system administrators | `string` | `"Domain Admins"` | no |
| <a name="input_ad_dns_ips"></a> [ad\_dns\_ips](#input\_ad\_dns\_ips) | DNS IP addresses for self-managed Active Directory | `list(string)` | n/a | yes |
| <a name="input_ad_domain_name"></a> [ad\_domain\_name](#input\_ad\_domain\_name) | Domain name for self-managed Active Directory | `string` | n/a | yes |
| <a name="input_ad_ou_dn"></a> [ad\_ou\_dn](#input\_ad\_ou\_dn) | Organizational Unit Distinguished Name | `string` | `null` | no |
| <a name="input_ad_secret_name"></a> [ad\_secret\_name](#input\_ad\_secret\_name) | Name of the Secrets Manager secret containing AD credentials | `string` | n/a | yes |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDR blocks allowed to access FSx | `list(string)` | <pre>[<br/>  "10.0.0.0/8"<br/>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment, i.e. dev, stage, prod | `string` | `"poc"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of the project, i.e. arc | `string` | `"arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"ap-south-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_fsx_dns_name"></a> [fsx\_dns\_name](#output\_fsx\_dns\_name) | FSx DNS name for mounting |
| <a name="output_fsx_id"></a> [fsx\_id](#output\_fsx\_id) | FSx file system ID |
| <a name="output_remote_administration_endpoint"></a> [remote\_administration\_endpoint](#output\_remote\_administration\_endpoint) | Remote administration endpoint |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID created for FSx |
<!-- END_TF_DOCS -->