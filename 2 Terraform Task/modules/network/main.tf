# Creating Public Subnet
resource "aws_subnet" "publicsubnet" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.subnet_cidr[0]
  availability_zone = "eu-north-1"
  map_public_ip_on_launch = true
  tags = {
    Name = var.publicsubnet_name[0]
  }
}
