# Create the overall vpc
module "vpc" {
  source = "./modules/vpc"
}

# Create the networking components: subnets, routing, gateways
module "network" {
  source = "./modules/network"

  vpc_id = module.vpc.vpc_id
}

# Create the load balancer components: EC2, Routing Table, auto scaling
module "lb" {
  source = "./modules/lb"

  vpc_id = module.vpc.vpc_id
  subnet_id1 = module.network.subnet_id1
  subnet_id2 = module.network.subnet_id2
}

# # Create the S3 components
# module "s3" {
#   source = "./modules/s3"
# }
