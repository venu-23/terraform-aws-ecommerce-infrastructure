module "vpc" {
  source = "../../modules/vpc"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}


module "security_groups" {
  source = "../../modules/security_groups"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}


module "alb" {
  source = "../../modules/alb"

  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
}


module "iam" {
  source = "../../modules/iam"

  environment = var.environment
}
