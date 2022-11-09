# Defining CIDR Block for subnet
variable "subnet_cidr" {
  description = "Define the subnet cidr_blocks"
  type = list
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
