<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| <a name="module_fsx_ontap_complete"></a> [fsx\_ontap\_complete](#module\_fsx\_ontap\_complete) | ../.. | n/a |
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
| <a name="output_fsx_id"></a> [fsx\_id](#output\_fsx\_id) | FSx file system ID |
| <a name="output_ontap_endpoints"></a> [ontap\_endpoints](#output\_ontap\_endpoints) | ONTAP endpoints |
| <a name="output_svm_ids"></a> [svm\_ids](#output\_svm\_ids) | Storage Virtual Machine IDs |
| <a name="output_volume_ids"></a> [volume\_ids](#output\_volume\_ids) | ONTAP Volume IDs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
