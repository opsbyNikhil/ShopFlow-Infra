output "instance_ids" {
  value = { for k, v in aws_instance.instance : k => v.id }
}

output "public_ips" {
  value = { for k, v in aws_instance.instance : k => v.public_ip }
}

output "private_ips" {
  value = {
    for k, v in aws_instance.instance : k => v.private_ip
  }
}