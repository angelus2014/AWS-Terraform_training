# Define CIDR Block for subnet
variable "subnet_cidr" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Define the name of the subnets
variable "subnet_name" {
  type    = list(any)
  default = ["Public Subnet", "Private Subnet"]
}

variable "vpc_id" {
  type = string
}

# Define the name of the route tables
variable "route_name" {
  type    = list(any)
  default = ["Public Route", "Private Route"]
}
