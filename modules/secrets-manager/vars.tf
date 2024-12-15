variable "secret_name" {
  description = "The name of the secret"
  type        = string
}

variable "secret_description" {
  description = "The description of the secret"
  type        = string
  default     = ""
}

variable "secret_string" {
  description = "The secret string to store"
  type        = string
}
