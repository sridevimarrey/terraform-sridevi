module "vpc" {
  source             = "./modules/VPC"
  vpc_cidr           = var.vpc_cidr
  subnet_cidr        = var.subnet_cidr
  availability_zone  = var.availability_zone
}

module "ec2" {
  source            = "./modules/EC2"
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.vpc.security_group_id
}


