variable "role_name" {
  description = "The name of the IAM role"
  type        = string
}

variable "policy_name" {
  description = "The name of the IAM policy"
  type        = string
  default     = "value"
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  type        = string
  default     = "value"
}

variable "is_dms_role" {
  description = "Determine the service role"
  type        = bool
  default     = false
}
variable "is_secret_role" {
  description = "Determine the service role"
  type        = bool
  default     = false
}

variable "resources" {
  description = "List of ARNs for the secrets this role should have access to"
  type        = list(string)
  default     = ["value"]
}

variable "is_lambda_role" {
  description = "Determine the service role"
  type        = bool
  default     = false
}
variable "is_step_functions_role" {
  description = "Should the Step Functions role be created"
  type        = bool
  default     = false
}

variable "is_glue_job" {
  description = "Should the Step Functions role be created"
  type        = bool
  default     = false
}
