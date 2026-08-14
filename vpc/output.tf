output "vpc_info" {
    value = {
        vpc_id = aws_vpc.vpc.id
        vpc_cidr = aws_vpc.vpc.cidr_block
    }
}