<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fsx_openzfs_complete"></a> [fsx\_openzfs\_complete](#module\_fsx\_openzfs\_complete) | ../.. | n/a |
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
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment, i.e. dev, stage, prod | `string` | `"poc"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace of the project, i.e. arc | `string` | `"arc"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_ids"></a> [backup\_ids](#output\_backup\_ids) | FSx Backup IDs |
| <a name="output_fsx_dns_name"></a> [fsx\_dns\_name](#output\_fsx\_dns\_name) | FSx DNS name |
| <a name="output_fsx_id"></a> [fsx\_id](#output\_fsx\_id) | FSx file system ID |
| <a name="output_root_volume_id"></a> [root\_volume\_id](#output\_root\_volume\_id) | Root volume ID |
| <a name="output_snapshot_ids"></a> [snapshot\_ids](#output\_snapshot\_ids) | OpenZFS Snapshot IDs |
| <a name="output_volume_ids"></a> [volume\_ids](#output\_volume\_ids) | OpenZFS Volume IDs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
