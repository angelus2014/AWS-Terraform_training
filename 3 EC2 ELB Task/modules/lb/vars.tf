# Create the variable for the SSH key
variable "key_name" {
  type    = string
  default = "My Key"
}

# Create the variable for the public subnet
variable "subnet_id1" {
  type    = string
  default = "10.99.0.0/24"
}

# Create the variable for the private subnet
variable "subnet_id2" {
  type    = string
  default = "10.99.1.0/24"
}

# Set up the variable for the VPC zone
variable "vpc_zone_identifier" {
  type    = list(string)
  default = null
}
