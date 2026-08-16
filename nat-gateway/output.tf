output "nat_gateway_id" {
  value = var.enable_nat_gateway ? aws_nat_gateway.nat[0].id : null
}

output "nat_eip" {
  value = var.enable_nat_gateway ? aws_eip.nat[0].public_ip : null
}