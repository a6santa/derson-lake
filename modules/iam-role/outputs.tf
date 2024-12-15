output "dms_s3_role_arn" {
  value = var.is_dms_role ? aws_iam_role.dms_s3_role[0].arn : ""
}

output "secret_manager_iam_role_arn" {
  value = var.is_secret_role ? aws_iam_role.secrets_manager_access_role[0].arn : ""
}

output "lambda_iam_role_arn" {
  value = var.is_lambda_role ? aws_iam_role.lambda_role[0].arn : ""
}

output "step_functions_role_arn" {
  value = var.is_step_functions_role ? aws_iam_role.step_functions_role[0].arn : ""
}

output "glue_job_role_arn" {
  value = var.is_glue_job ? aws_iam_role.glue_job_role[0].arn : ""
}
