output "vpc_id" {
  value = module.vpc.vpc_info.vpc_id
}

output "vpc_cidr" {
  value = module.vpc.vpc_info.vpc_cidr
}

output "subnet" {
  value = module.subnet
}

output "igw_id" {
  value = module.internet-gateway.igw_id
}

output "nat_gateway_id" {
  value = module.nat-gateway.nat_gateway_id
}

output "nat_eip" {
  value = module.nat-gateway.nat_eip
}

output "route_table_id" {
  value = module.route-table.route_table_id
}

output "security_group_id" {
  value = module.security-group.sg_id
}

# output "instance_ids" {
#   value = module.ec2.instance_ids
# }

# output "public_ips" {
#   value = module.ec2.public_ips
# }

# output "ec2_private_ips" {
#   value = module.ec2.private_ips
# }
output "asg_ids" {
  value = module.asg.asg_ids
}

output "asg_names" {
  value = module.asg.asg_names
}

output "asg_arns" {
  value = module.asg.asg_arns
}

output "launch_template_ids" {
  value = module.asg.launch_template_ids
}

output "scale_out_policy_arns" {
  value = module.asg.scale_out_policy_arns
}

output "cpu_alarm_names" {
  value = module.asg.cpu_alarm_names
}

output "s3_bucket_id" {
  value = module.s3.bucket_id
}

output "s3_bucket_arn" {
  value = module.s3.bucket_arn
}

output "s3_bucket_region" {
  value = module.s3.bucket_region
}