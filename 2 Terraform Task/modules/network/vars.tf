# Defining CIDR Block for subnet
variable "subnet_cidr" {
  description = "Define the subnet cidr_blocks"
  type = list
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

# Define the name of the subnets
variable "subnet_name" {
  description = "Define the names of the subnets"
  type = list
  default = ["Public Subnet", "Private Subnet"]
}

variable "vpc_id" {
  type = string
}

# Defining the name of the route tables
variable "route_name" {
  description = "Defining the name of the public route table"
  type = list
  default = ["Public Route", "Private Route"]
}
