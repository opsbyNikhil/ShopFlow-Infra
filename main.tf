module "vpc" {
    source = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/vpc"
    vpc_info = {
        vpc_cidr = "10.0.0.0/16"
        vpc_tags =  "shopflow-dev-vpc-01"
    }
}

module "subnet" {
    source = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/subnets"
    vpc_info = module.vpc.vpc_info
    subnet_info = {
        subnets = [ {
                subnet_cidr = [
                    "10.0.1.0/24", 
                    "10.0.2.0/24", 
                    "10.0.3.0/24"
                ]
                subnet_az = [
                    "ap-southeast-1a", 
                    "ap-southeast-1b", 
                    "ap-southeast-1c"
                ]
                subnet_names = [
                    "shopflow-dev-public-subnet-1a", 
                    "shopflow-dev-public-subnet-1b", 
                    "shopflow-dev-public-subnet-1c"
                ]
        } ]
    }
}
