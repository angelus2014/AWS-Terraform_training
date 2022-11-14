# Create the overall vpc
module "vpc" {
  source = "./modules/vpc"
}

# Create the networking components: subnets, routing, gateways
module "network" {
  source = "./modules/network"

  vpc_id = module.vpc.vpc_id
}

# Create the ec2 components: EC2, Routing Table
module "ec2" {
  source = "./modules/ec2"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.network.subnet_id
}
