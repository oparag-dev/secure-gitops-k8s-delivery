module "core" {
  source = "../modules/core"

  project_name = var.project_name
  aws_region   = var.aws_region
  azs          = var.azs
  environment  = var.environment
}


module "vpc" {
  source = "../modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  nat_gateway_enabled = var.nat_gateway_enabled
  single_nat_gateway  = var.single_nat_gateway
}

module "rds" {
  source = "../modules/rds"

  project_name       = var.project_name
  private_subnet_ids = module.vpc.private_subnet_ids
  security_group_ids = [module.vpc.database_security_group_id]

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
}


module "kops_state_bucket" {
  source = "../modules/s3"

  bucket_name  = var.kops_state_bucket_name
  project_name = var.project_name
}

module "dns" {
  source = "../modules/dns"

  domain_name = var.domain_name
}