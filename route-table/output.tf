output "route_table_id" {
  value = {
    for name, route_table in aws_route_table.route_table :
    name => route_table.id
  }
}

output "public_route_table_id" {
  value = aws_route_table.route_table["public"].id
}

output "private_route_table_id" {
  value = aws_route_table.route_table["private"].id
}