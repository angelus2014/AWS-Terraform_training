# Defining the VPC name
variable "vpc_name" {
  description = "The name of the VPC"
  type = string
  default = "Terraform VPC"
}

# Defining CIDR Block for VPC
variable "vpc_cidr" {
  description = "Define the CIDR for the VPC"
  type = string
  default = "10.0.0.0/16"
}
