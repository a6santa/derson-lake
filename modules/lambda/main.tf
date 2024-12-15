data "archive_file" "lambda_zip_file" {
  type = "zip"

  source_dir  = var.lambda_function_name
  output_path = "${var.lambda_function_name}.zip"
}

resource "aws_s3_object" "lambda_object" {
  bucket = var.lambda_bucket

  key    = "${var.lambda_function_name}.zip"
  source = data.archive_file.lambda_zip_file.output_path

  etag = filemd5(data.archive_file.lambda_zip_file.output_path)

  depends_on = [
    data.archive_file.lambda_zip_file
  ]
}

resource "aws_lambda_function" "this" {
  function_name = var.lambda_function_name

  s3_bucket = var.lambda_bucket
  s3_key    = aws_s3_object.lambda_object.key

  runtime          = var.lambda_runtime
  handler          = var.lambda_handler
  description      = var.lambda_description
  memory_size      = var.memory_size
  layers           = var.lambda_layers
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  role             = var.lambda_role_arn

  timeout = var.timeout_lambda

  ephemeral_storage {
    size = var.ephemeral_storage
  }

  environment {
    variables = var.env_vars
  }

  tags = {
    Project   = "DersonLake"
    Managedby = "Terraform"
    Author    = "AndersonSantana"
  }

  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_s3_object.lambda_object
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7
}