output "id" {
  value = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.existing_vpc[0].id
}

output "private_subnet_ids" {
  value = var.create_vpc ? module.vpc[0].private_subnets : data.aws_subnets.existing_vpc[0].ids
}
