resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = {
    Name = "shopflow-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "shopflow-nat-gateway"
  }

  depends_on = [aws_eip.nat]
}

resource "aws_route" "private_nat_route" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = var.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}