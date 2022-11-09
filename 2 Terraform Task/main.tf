module "vpc" {
  source = "./modules/vpc"
}

module "network" {
  source = "./modules/network"

  vpc_id = module.vpc.vpc_id
}
