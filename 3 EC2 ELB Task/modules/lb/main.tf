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

resource "aws_lb" "web_alb" {
  name            = "web-alb"
  security_groups = [aws_security_group.sg.id]
  subnets = [
    var.subnet_id1,
    var.subnet_id2
  ]
  cross_zone_load_balancing = true
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }
}
