# Create the load balancer components: EC2, Routing Table, auto scaling
module "lb" {
  source = "./modules/lb"
}
