module "vpc" {
    source = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/vpc"
    vpc_info = {
        vpc_cidr = "10.0.0.0/16"
        vpc_tags =  "shopflow-dev-vpc-01"
    }
}