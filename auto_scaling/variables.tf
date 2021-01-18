variable "vpc_id" {}

variable "master_ip" {}
variable "security_groups" {
  type = list
}

variable "subnet1" {}
variable "subnet2" {}

variable "target_group_arn" {}