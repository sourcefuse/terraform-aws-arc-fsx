# AWS FSx Terraform Module

A production-grade, reusable Terraform module for provisioning AWS FSx file systems with support for all FSx variants and associated resources.

## Features

- **Multi-FSx Support**: Windows File Server, Lustre, NetApp ONTAP, and OpenZFS
- **File Cache**: FSx File Cache for high-performance caching
- **Volumes**: ONTAP and OpenZFS volume management
- **Storage Virtual Machines**: ONTAP SVM creation and configuration
- **Snapshots**: OpenZFS snapshot management
- **Backups**: Manual backup creation and management
- **Security**: SourceFuse ARC Security Group module with protocol-specific rules
- **Active Directory**: Support for both AWS Managed AD and self-managed AD
- **S3 Integration**: Data repository associations for Lustre file systems
- **Backup Management**: Configurable automatic backups and retention
- **Encryption**: KMS encryption support for data at rest
- **IAM Integration**: Optional IAM role creation with least-privilege policies
- **Flexible Networking**: Multi-AZ and single-AZ deployment options

## FSx Component Support Matrix

| Component | Windows | Lustre | ONTAP | OpenZFS | File Cache |
|-----------|---------|--------|-------|---------|------------|
| File Systems | ✅ | ✅ | ✅ | ✅ | ✅ |
| Volumes | ❌ | ❌ | ✅ | ✅ | ❌ |
| Storage Virtual Machines | ❌ | ❌ | ✅ | ❌ | ❌ |
| Snapshots | ❌ | ❌ | ❌ | ✅ | ❌ |
| Backups | ✅ | ✅ | ✅ | ✅ | ❌ |
| Data Repository | ❌ | ✅ | ❌ | ❌ | ❌ |
| Multi-AZ | ✅ | ❌ | ✅ | ✅ | ❌ |
| S3 Integration | ❌ | ✅ | ❌ | ❌ | ❌ |

## Usage

### Basic Windows File Server

```hcl
module "fsx_windows" {
  source = "path/to/fsx-module"

  name        = "my-windows-fsx"
  environment = "prod"
  fsx_type    = "windows"

  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678"]

  storage_capacity    = 32
  throughput_capacity = 8
  deployment_type     = "SINGLE_AZ_2"

  active_directory_id = "d-1234567890"
  
  tags = {
    Project = "File Sharing"
  }
}
```

### Lustre with S3 Integration

```hcl
module "fsx_lustre" {
  source = "path/to/fsx-module"

  name        = "my-lustre-fsx"
  environment = "prod"
  fsx_type    = "lustre"

  vpc_id     = "vpc-12345678"
  subnet_ids = ["subnet-12345678"]

  storage_capacity            = 1200
  deployment_type            = "PERSISTENT_2"
  per_unit_storage_throughput = 250

  import_path = "s3://my-bucket/data/"
  export_path = "s3://my-bucket/results/"

  data_repository_associations = {
    main = {
      data_repository_path = "s3://my-bucket/data/"
      file_system_path     = "/data"
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create | Whether to create FSx resources | `bool` | `true` | no |
| name | Name prefix for FSx resources | `string` | `""` | no |
| environment | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| fsx_type | Type of FSx file system to create | `string` | `"windows"` | no |
| storage_capacity | Storage capacity of the file system in GiB | `number` | n/a | yes |
| subnet_ids | List of subnet IDs for the file system | `list(string)` | n/a | yes |
| vpc_id | VPC ID where the file system will be created | `string` | n/a | yes |
| throughput_capacity | Throughput capacity in MB/s | `number` | `null` | no |
| deployment_type | Deployment type for the file system | `string` | `null` | no |
| storage_type | Storage type (SSD or HDD) | `string` | `"SSD"` | no |
| kms_key_id | KMS key ID for encryption | `string` | `null` | no |
| active_directory_id | AWS Managed Microsoft AD ID | `string` | `null` | no |
| create_security_group | Whether to create a security group for FSx | `bool` | `true` | no |
| allowed_cidr_blocks | CIDR blocks allowed to access FSx | `list(string)` | `["10.0.0.0/8"]` | no |
| tags | Additional tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| fsx_id | ID of the FSx file system |
| fsx_arn | ARN of the FSx file system |
| fsx_dns_name | DNS name of the FSx file system |
| fsx_network_interface_ids | Network interface IDs of the FSx file system |
| security_group_id | ID of the created security group |
| iam_role_arn | ARN of the created IAM role |

## Examples

- [Basic Windows File Server](./examples/basic-windows/) - Single-AZ Windows file server with AWS Managed AD
- [Windows with Self-Managed AD](./examples/windows-self-managed-ad/) - Windows file server with custom Active Directory
- [Lustre with S3 Integration](./examples/lustre-s3-integration/) - High-performance Lustre with S3 data repository
- [ONTAP Multi-Protocol](./examples/ontap-multi-protocol/) - NetApp ONTAP with NFS, SMB, and iSCSI support
- [Custom Security and KMS](./examples/custom-security-kms/) - Advanced security configuration with custom KMS keys

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   VPC Subnets   │    │  Security Group │    │   FSx System    │
│                 │────│                 │────│                 │
│ Multi-AZ Support│    │ Protocol Rules  │    │ Windows/Lustre/ │
└─────────────────┘    └─────────────────┘    │ ONTAP/OpenZFS   │
                                              └─────────────────┘
                              │
                    ┌─────────────────┐
                    │  Optional IAM   │
                    │      Role       │
                    └─────────────────┘
```

## Security Considerations

- Security groups are created with minimal required ports for each FSx type
- KMS encryption is supported for data at rest
- IAM roles follow least-privilege principles
- Network access is restricted to specified CIDR blocks
- Backup encryption is enabled by default

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Support

For issues and questions:
- Create an issue in this repository
- Check the [examples](./examples/) directory for common use cases
- Review AWS FSx documentation for service-specific requirements
