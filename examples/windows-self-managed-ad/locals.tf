locals {
  ad_credentials = jsondecode(
    data.aws_secretsmanager_secret_version.ad_join.secret_string
  )
}