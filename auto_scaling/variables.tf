variable "vpc_id" {}


variable "security_groups" {
  type = list
}

variable "subnet1" {}
variable "subnet2" {}

variable "target_group_arn" {}