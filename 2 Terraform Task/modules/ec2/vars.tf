variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "key_name" {
  type    = string
  default = "My Key"
}

# Define the name of the Security Group
variable "sg_name" {
  type    = string
  default = "Security Group"
}

# Define the name of the EC2 in the Public Subnet
variable "pub_ec2_name" {
  type    = string
  default = "Public Subnet EC2"
}
