variable "cluster_name" {}

variable "create_vpc" {
  default = true
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc_name" {}

variable "admin_iam_role" {}
