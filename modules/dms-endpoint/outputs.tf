output "mysql_endpoint_arn" {
  value = element(concat(aws_dms_endpoint.mysql_endpoint[*].endpoint_arn, [""]), 0)
}

output "s3_target_endpoint_arn" {
  value = element(concat(aws_dms_endpoint.s3_target_endpoint[*].endpoint_arn, [""]), 0)
}