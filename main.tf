provider "aws" {
  profile = "derson_profile"
}

module "raw_storage" {
  source      = "./modules/s3"
  bucket_name = "derson-lake-raw"
  layer       = "Raw"
}

module "iam_role" {
  source      = "./modules/iam-role"
  is_dms_role = true
  role_name   = "dms_s3_role"
  policy_name = "dms_s3_policy"
  resources   = [module.raw_storage.bucket_arn]
  depends_on  = [module.raw_storage]
}

module "s3_dms_endpoint" {
  source                  = "./modules/dms-endpoint"
  is_s3                   = true
  endpoint_name           = "s3-lake-endpoint-1"
  bucket_name             = "derson-lake-raw"
  service_access_role_arn = module.iam_role.dms_s3_role_arn
  bucket_folder           = "derson_base"
  compression_type        = "GZIP"
  depends_on              = [module.iam_role, module.raw_storage]
}

module "mysql_dms_endpoint" {
  source        = "./modules/dms-endpoint"
  is_mysql      = true
  endpoint_name = "mysql-endpoint-source-1"
  password      = "my_password"
  port          = 3306
  server_name   = "my_server_name"
  username      = "my_username"
}

module "lambda_role" {
  source         = "./modules/iam-role"
  is_lambda_role = true
  role_name      = "lambda_dms_cloudwatch_role"
}

module "DMS-intake" {
  source               = "./modules/lambda"
  lambda_function_name = "DMS-intake"
  lambda_description   = "Function for data intake with DMS"
  lambda_role_arn      = module.lambda_role.lambda_iam_role_arn
  lambda_runtime       = "python3.9"
  lambda_handler       = "lambda_function.lambda_handler"
  memory_size          = 512
  timeout_lambda       = 180
  depends_on           = [module.lambda_role]
}

module "pipeline_role" {
  source                 = "./modules/iam-role"
  is_step_functions_role = true
  role_name              = "step_function_full_role"
  policy_name            = "step_function_full_policy"
}

module "pipeline-dms-error" {
  source                 = "./pipelines/DMS-ErrorHandling"
  iam_state_machine_role = module.pipeline_role.step_functions_role_arn
  depends_on = [
    module.pipeline_role
  ]
}

module "pipeline-dms-handler" {
  source                 = "./pipelines/DMS-Handler"
  iam_state_machine_role = module.pipeline_role.step_functions_role_arn
  depends_on = [
    module.pipeline_role
  ]
}

module "pipeline-derson-main" {
  source                 = "./pipelines/derson-Main"
  iam_state_machine_role = module.pipeline_role.step_functions_role_arn
  depends_on = [
    module.pipeline_role
  ]
}