resource "aws_subnet" "Subnets" {
    vpc_id = var.vpc_info.vpc_id
    count = length(var.subnet_info.subnets[0].subnet_cidr)
    cidr_block = var.subnet_info.subnets[0].subnet_cidr[count.index]
    availability_zone = var.subnet_info.subnets[0].subnet_az[count.index]
    tags = {
        Name = var.subnet_info.subnets[0].subnet_names[count.index]
    }

}