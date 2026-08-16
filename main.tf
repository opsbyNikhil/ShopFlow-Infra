module "vpc" {
  source = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/vpc"
  vpc_info = {
    vpc_cidr = var.vpc_cidr
    vpc_tags = "${var.project}-${var.env}-${var.resource_name}-${var.number}"
  }
}

module "subnet" {
  source   = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/subnets"
  vpc_info = module.vpc.vpc_info
  subnet_info = {
    frontend = var.subnets.frontend
    backend  = var.subnets.backend
  }
}

module "internet-gateway" {
  source                = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/internet-gateway"
  vpc_id                = module.vpc.vpc_info.vpc_id
  internet_gateway_name = var.igw_info.igw
}

module "nat-gateway" {
  source = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/nat-gateway"

  enable_nat_gateway = var.enable_nat_gateway

  vpc_id = module.vpc.vpc_info.vpc_id

  public_subnet_id = module.subnet.frontend_subnet_ids[0]

  private_route_table_id = module.route-table.private_route_table_id
}

module "route-table" {
  source = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/route-table"

  vpc_id = module.vpc.vpc_info.vpc_id

  route_table_info = {
    public = {
      route_table_name = "${var.project}-${var.env}-public-rt-${var.number}"
      route_table_cidr = var.route_table_cidr
      gateway_id       = module.internet-gateway.igw_id
    }

    private = {
      route_table_name = "${var.project}-${var.env}-private-rt-${var.number}"
      route_table_cidr = var.route_table_cidr
      gateway_id       = null
    }
  }

  subnet_ids = {
    public  = module.subnet.frontend_subnet_ids
    private = module.subnet.backend_subnet_ids
  }
}

module "security-group" {
  source = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/security-group"
  vpc_id = module.vpc.vpc_info.vpc_id
  security_group-info = {
    sg_name        = "${var.project}-${var.env}-${var.number}"
    sg_description = "Security group for ${var.project}-${var.env} application"
    sg_tags        = "${var.project}-${var.env}-sg-${var.number}"
  }

  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
}

module "ami" {
  source = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/ami"
  ami_info = {
    exist_ami   = var.ami_info.exist_ami
    exist_owner = var.ami_info.exist_owner
  }
}

module "key_pair" {
  source       = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/key_pair"
  aws_key_pair = local.aws_key_pair
}

# module "ec2" {
#   source = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/ec2"

#   ec2_info = {
#     frontend = {
#       ami                         = module.ami.ami
#       instance_type               = var.ec2-instances["frontend"].instance_type
#       associate_public_ip_address = true
#       key_name                    = module.key_pair.key_name
#       subnet_id                   = module.subnet.frontend_subnet_ids[0]
#       ec2_tags                    = "${var.project}-${var.env}-${var.ec2-instances["frontend"].tier}-ec2-${var.number}"
#       vpc_security_group_ids      = [module.security-group.sg_id]
#     }

#     backend = {
#       ami                         = module.ami.ami
#       instance_type               = var.ec2-instances["backend"].instance_type
#       associate_public_ip_address = false
#       key_name                    = module.key_pair.key_name
#       subnet_id                   = module.subnet.backend_subnet_ids[0]
#       ec2_tags                    = "${var.project}-${var.env}-${var.ec2-instances["backend"].tier}-ec2-${var.number}"
#       vpc_security_group_ids      = [module.security-group.sg_id]
#     }
#   }
# }


module "asg" {
  source = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/asg"

  asg_info = {
    frontend = {
      tier     = var.ec2-instances["frontend"].tier
      asg_name = "${var.project}-${var.env}-${var.ec2-instances["frontend"].tier}-ec2-${var.number}"

      ami                         = module.ami.ami
      instance_type               = var.ec2-instances["frontend"].instance_type
      key_name                    = module.key_pair.key_name
      associate_public_ip_address = true
      subnet_ids                  = module.subnet.frontend_subnet_ids
      vpc_security_group_ids      = [module.security-group.sg_id]

      min_size                  = var.asg_settings.min_size
      desired_capacity          = var.asg_settings.desired_capacity
      max_size                  = var.asg_settings.max_size
      cpu_threshold             = var.asg_settings.cpu_threshold
      health_check_grace_period = var.asg_settings.health_check_grace_period
    }

    backend = {
      tier     = var.ec2-instances["backend"].tier
      asg_name = "${var.project}-${var.env}-${var.ec2-instances["backend"].tier}-ec2-${var.number}"

      ami                         = module.ami.ami
      instance_type               = var.ec2-instances["backend"].instance_type
      key_name                    = module.key_pair.key_name
      associate_public_ip_address = false
      subnet_ids                  = module.subnet.backend_subnet_ids
      vpc_security_group_ids      = [module.security-group.sg_id]

      min_size                  = var.asg_settings.min_size
      desired_capacity          = var.asg_settings.desired_capacity
      max_size                  = var.asg_settings.max_size
      cpu_threshold             = var.asg_settings.cpu_threshold
      health_check_grace_period = var.asg_settings.health_check_grace_period
    }
  }
}

module "s3" {
  source = "D:/Magneq/DevOps/End-to-End/repo/ShopFlow-Infra/s3"

  enable_s3 = var.enable_s3

  bucket_info = {
    bucket_name        = var.s3_info.bucket_name
    versioning_enabled = var.s3_info.versioning_enabled
    force_destroy      = var.s3_info.force_destroy
  }
}