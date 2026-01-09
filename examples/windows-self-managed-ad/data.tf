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
