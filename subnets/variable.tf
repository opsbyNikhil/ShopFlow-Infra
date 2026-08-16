variable "vpc_info" {
  type = object({
    vpc_id   = string
    vpc_cidr = string
  })
}

variable "subnet_info" {
  type = object({
    frontend = list(object({
      subnet_name = string
      subnet_az   = string
      subnet_cidr = string
    }))

    backend = list(object({
      subnet_name = string
      subnet_az   = string
      subnet_cidr = string
    }))
  })
}