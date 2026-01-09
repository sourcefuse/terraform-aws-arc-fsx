# Fetch VPC by Name
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["arc-poc-vpc"]
  }
}

# Fetch Private Subnets by Name pattern
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}
