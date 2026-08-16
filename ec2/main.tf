resource "aws_instance" "instance" {
  for_each = var.ec2_info

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  associate_public_ip_address = each.value.associate_public_ip_address
  vpc_security_group_ids      = each.value.vpc_security_group_ids
  key_name                    = each.value.key_name
  subnet_id                   = each.value.subnet_id

  tags = {
    Name = each.value.ec2_tags
    Tier = each.key
  }
}