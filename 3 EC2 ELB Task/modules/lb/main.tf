# Creating Security Group
resource "aws_security_group" "sg" {
  tags = {
    Name = var.sg_name
  }
  vpc_id = var.vpc_id
  # key_name = var.key_name

  # Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = file("${abspath(path.cwd)}/my-key.pub")
}

# Create an EC2 instance in Public Subnet
resource "aws_instance" "ec2instance1" {
  ami                         = "ami-02aeff1a953c5c2ff"
  instance_type               = "t3.micro"
  user_data                   = templatefile("my_amazon_script.tftpl", { request_id = "nginx" })
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = var.subnet_id1
  associate_public_ip_address = true
  tags = {
    Name = var.pub_ec2_name[0]
  }
}

# Create an EC2 instance in Private Subnet
resource "aws_instance" "ec2instance2" {
  ami                         = "ami-02aeff1a953c5c2ff"
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = var.subnet_id2
  associate_public_ip_address = false
  tags = {
    Name = var.pub_ec2_name[1]
  }
}
