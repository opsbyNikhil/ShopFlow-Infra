variable "vpc_info" {
    type = object({
        vpc_id = string
        vpc_cidr = string
    })
}

variable "subnet_info" {
    type = object({
        subnets = list(object({
            subnet_cidr = list(string)
            subnet_az = list(string)
            subnet_names = list(string)
        }))
    })
    
}