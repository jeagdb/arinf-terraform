variable "vpc_id" {}

variable "subnets" {
  type = list
}

variable "instances" {
  type = list
}

variable "security_group" {
}