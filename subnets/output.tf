output "frontend_subnet_ids" {
  value = aws_subnet.frontend[*].id
}

output "backend_subnet_ids" {
  value = aws_subnet.backend[*].id
}

output "subnet_id" {
  value = concat(
    aws_subnet.frontend[*].id,
    aws_subnet.backend[*].id
  )
}