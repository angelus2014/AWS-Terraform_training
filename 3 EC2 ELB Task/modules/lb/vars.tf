# Create the variable for the SSH key
variable "key_name" {
  type    = string
  default = "My Key"
}

# Set up the variable for the VPC zone
variable "vpc_zone_identifier" {
  type    = list(string)
  default = null
}
