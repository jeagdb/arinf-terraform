variable "my_public_key" {}

variable "instance_type" {}

variable "security_group" {}

variable "public_subnets" {
  type = list
}

variable "private_subnets" {
  type = list
}

variable "public_instance_count" {}
variable "private_instance_count" {}