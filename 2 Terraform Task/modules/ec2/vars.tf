variable "vpc_id" {
  type = string
}

# Defining the name of the Security Group
variable "sg_name" {
  description = "Defining the name of the Security Group"
  type = string
  default = "Security Group"
}
