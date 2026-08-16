resource "aws_security_group" "public_sg" {
  vpc_id      = var.vpc_id
  name        = var.security_group-info.sg_name
  description = var.security_group-info.sg_description
  tags = {
    Name = var.security_group-info.sg_tags
  }
}

resource "aws_vpc_security_group_ingress_rule" "inbound" {
  count             = length(var.ingress_rules)
  security_group_id = aws_security_group.public_sg.id
  description       = var.ingress_rules[count.index].description
  cidr_ipv4         = var.ingress_rules[count.index].cidr_ipv4
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  ip_protocol       = var.ingress_rules[count.index].ip_protocol

}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  count             = length(var.egress_rules)
  security_group_id = aws_security_group.public_sg.id
  description       = var.egress_rules[count.index].description
  cidr_ipv4         = var.egress_rules[count.index].cidr_ipv4
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  ip_protocol       = var.egress_rules[count.index].ip_protocol
}