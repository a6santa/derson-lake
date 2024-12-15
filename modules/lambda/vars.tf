variable "lambda_function_name" {
    type = string
}

variable "lambda_bucket" {
  type = string
  default = "derson-lambdas"
}

variable "lambda_role_arn" {
  type = string
}

variable "lambda_description" {
  type = string
}
variable "lambda_runtime" {
  type = string
}

variable "lambda_handler" {
  type = string
}

variable "lambda_layers" {
  type = list
  default = []
}

variable "ephemeral_storage" {
  type = number
  default = 512
}

variable "memory_size" {
  type = number
  default = 128
}

variable "timeout_lambda" {
    type = number
    default = 30
}

variable "env_vars" {
  type = map(string)
  default = {
    derson = "data"
  }
}
