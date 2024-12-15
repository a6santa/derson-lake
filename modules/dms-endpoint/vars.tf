variable "is_mysql" {
  description = "Flag to determine if the MySQL endpoint should be created"
  type        = bool
  default     = false
}

variable "is_s3" {
  description = "Flag to determine if the S3 endpoint should be created"
  type        = bool
  default     = false
}

variable "endpoint_name" {
  description = "The ID of the MySQL DMS endpoint"
  type        = string
  default = "value"
}

variable "secrets_manager_arn" {
  description = "The ARN of the Secrets Manager secret containing database credentials"
  type        = string
  default = "value"
}

variable "secrets_manager_access_role_arn" {
  description = "The ARN of the role that allows access to Secrets Manager"
  type        = string
  default = "value"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for the DMS target endpoint"
  type        = string
  default = "value"
}

variable "service_access_role_arn" {
  description = "The ARN of the IAM role for accessing AWS services"
  type        = string
  default = "value"
}

variable "bucket_folder" {
  description = "The folder within the S3 bucket to store data"
  type        = string
  default     = "/"
}

variable "compression_type" {
  description = "The compression type to use for the S3 target endpoint (e.g., 'gzip', 'none')"
  type        = string
  default     = "GZIP"
}

variable "password" {
  description = "Database Pwd"
  type        = string
  default     = ""

}
variable "port" {
  description = "Database port"
  type        = number
  default     = 9315

}
variable "server_name" {
  description = "dabase host"
  type        = string
  default     = ""

}

variable "username" {
  description = "Database username"
  type        = string
  default     = ""

}
