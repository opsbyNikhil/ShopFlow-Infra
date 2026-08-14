resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_info.vpc_cidr
    tags = {
        Name = var.vpc_info.vpc_tags
    }
}