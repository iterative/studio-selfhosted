variable "admin_users_arns" {
  type    = list(string)
  default = []
}

variable "cluster_name" {
  default = ""
}

variable "private_subnet_ids" {}

variable "vpc_id" {}
