variable "multi_az" {
  type    = bool
  default = false
}

variable "replication_instance_class" {
  type = string
}

variable "owner_name" {
  type = string
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = ["sg-36b76b40"]
}

variable "engine_version" {
  type    = string
  default = "3.4.6" # Mudar Versão
}

variable "publicly_accessible" {
  type    = bool
  default = false
}
