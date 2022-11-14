# Create Public Subnet
resource "aws_subnet" "publicsubnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr[0]
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = var.subnet_name[0]
  }
}

# Create Private Subnet
resource "aws_subnet" "privatesubnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidr[1]
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = var.subnet_name[1]
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id
}

# Create Route Table for Public Subnet
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
  subnet_id      = aws_subnet.publicsubnet.id
  route_table_id = aws_route_table.rt.id
}

# Create EIP
resource "aws_eip" "eip" {
  vpc = true
}

# Create NAT Gateway
resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.publicsubnet.id
}

# Create Route Table for NAT Gateway
resource "aws_route_table" "rt_NAT" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }
  tags = {
    Name = var.route_name[1]
  }
}
resource "aws_route_table_association" "rt_associate_private" {
  subnet_id      = aws_subnet.privatesubnet.id
  route_table_id = aws_route_table.rt_NAT.id
}
