# Create the network components
module "network" {
  source = "./modules/network"
}

# Create the load balancer and auto scaling components
module "lb" {
  source            = "./modules/lb"
  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_id
  private_subnet_id = module.network.private_subnet_id
}
