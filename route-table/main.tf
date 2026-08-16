resource "aws_route_table" "route_table" {
  for_each = var.route_table_info

  vpc_id = var.vpc_id

  tags = {
    Name = each.value.route_table_name
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.route_table["public"].id
  destination_cidr_block = var.route_table_info["public"].route_table_cidr
  gateway_id             = var.route_table_info["public"].gateway_id
}

locals {
  subnet_associations = {
    for item in flatten([
      for tier, subnet_list in var.subnet_ids : [
        for index, subnet_id in subnet_list : {
          key       = "${tier}-${index}"
          tier      = tier
          subnet_id = subnet_id
        }
      ]
    ]) :
    item.key => item
  }
}

resource "aws_route_table_association" "route_table_association" {
  for_each = local.subnet_associations

  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.route_table[each.value.tier].id
}