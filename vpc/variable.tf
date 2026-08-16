variable "vpc_info" {
  type = object({
    vpc_cidr = string
    vpc_tags = string
  })
}