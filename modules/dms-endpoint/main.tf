resource "aws_dms_endpoint" "mysql_endpoint" {
  count                           = var.is_mysql ? 1 : 0
  endpoint_id                     = var.endpoint_name
  endpoint_type                   = "source"
  engine_name                     = "mysql"
  password                        = var.password
  port                            = var.port
  server_name                     = var.server_name
  ssl_mode                        = "none"
  username                        = var.username

  tags = {
    Project   = "DersonLake"
    Managedby = "Terraform"
    Author    = "AndersonSantana"
  }
}

resource "aws_dms_endpoint" "s3_target_endpoint" {
  count         = var.is_s3 ? 1 : 0
  endpoint_id   = var.endpoint_name
  endpoint_type = "target"
  engine_name   = "s3"

  s3_settings {
    bucket_name             = var.bucket_name
    service_access_role_arn = var.service_access_role_arn
    bucket_folder           = var.bucket_folder
    data_format             = "parquet"
    compression_type        = var.compression_type
    timestamp_column_name = "intake_date"
  }

  tags = {
    Project   = "DersonLake"
    Managedby = "Terraform"
    Author    = "AndersonSantana"
  }
}
