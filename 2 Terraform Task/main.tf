module "vpc" {
  source = "./modules/vpc"
}

module "network" {
  source = "./modules/network"
}
