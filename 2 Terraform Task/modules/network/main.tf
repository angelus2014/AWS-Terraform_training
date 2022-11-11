# Creating Public Subnet
resource "aws_subnet" "publicsubnet" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr[0]
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet_name[0]
  }
}

# Creating Private Subnet
resource "aws_subnet" "privatesubnet" {
  vpc_id = var.vpc_id
  cidr_block = var.subnet_cidr[1]
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = var.subnet_name[1]
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
}

# Creating Route Table for Public Subnet
resource "aws_route_table" "rt" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = var.route_name[0]
  }
}
resource "aws_route_table_association" "rt_associate_public" {
  subnet_id = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.rt.id
}
