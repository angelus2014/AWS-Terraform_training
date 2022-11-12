# Defining the VPC name
variable "vpc_name" {
  type = string
  default = "Terraform VPC"
}

# Defining CIDR Block for VPC
variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}
