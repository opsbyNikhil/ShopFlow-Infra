resource "aws_subnet" "frontend" {
  count = length(var.subnet_info.frontend)

  vpc_id            = var.vpc_info.vpc_id
  cidr_block        = var.subnet_info.frontend[count.index].subnet_cidr
  availability_zone = var.subnet_info.frontend[count.index].subnet_az

  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_info.frontend[count.index].subnet_name
  }
}



resource "aws_subnet" "backend" {
  count = length(var.subnet_info.backend)

  vpc_id            = var.vpc_info.vpc_id
  cidr_block        = var.subnet_info.backend[count.index].subnet_cidr
  availability_zone = var.subnet_info.backend[count.index].subnet_az

  map_public_ip_on_launch = false

  tags = {
    Name = var.subnet_info.backend[count.index].subnet_name
  }
}