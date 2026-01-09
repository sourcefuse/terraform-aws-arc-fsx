# Fetch VPC by Name
data "aws_vpc" "ascend" {
  filter {
    name   = "tag:Name"
    values = ["ascend-vpc"]
  }
}

# Fetch Private Subnets by Name pattern
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.ascend.id]
  }

  filter {
    name   = "tag:Name"
    values = ["ascend-private-subnet-1a"]
  }
}


data "aws_secretsmanager_secret" "ad_join" {
  name = var.ad_secret_name
}

data "aws_secretsmanager_secret_version" "ad_join" {
  secret_id = data.aws_secretsmanager_secret.ad_join.id
}

locals {
  ad_credentials = jsondecode(
    data.aws_secretsmanager_secret_version.ad_join.secret_string
  )
}