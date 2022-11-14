variable "vpc_id" {
  type = string
}

variable "subnet_id1" {
  type = string
}

variable "subnet_id2" {
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
  type    = list(any)
  default = ["Public EC2", "Private EC2"]
}
