resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = file("${abspath(path.cwd)}/my-key.pub")
}

locals {
  tags = {
    Environment = "demo"
    Blog        = "auto-scaling-group-setup"
  }
}

# Launch template
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2",
    ]
  }
}

# data "aws_subnets" "private" {
#   filter {
#     name   = "tag:Name"
#     values = ["private"]
#   }
# }

resource "aws_launch_template" "this" {
  name_prefix   = "${var.asg_name}-launch-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    # subnet_id                   = var.private_subnet_id
    subnet_id       = element(var.private_subnet_id, 0)
    security_groups = [module.asg_sg.security_group_id]
  }
  key_name = var.key_name
  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
module "auto-scaling-group-demo" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "external-${var.asg_name}"

  vpc_zone_identifier = var.private_subnet_id
  # vpc_zone_identifier = element(var.private_subnet_id, 0)
  security_groups  = [module.asg_sg.security_group_id]
  min_size         = 0
  max_size         = 1
  desired_capacity = 1

  create_launch_template = false
  launch_template        = aws_launch_template.this.name
  # user_data              = base64encode(local.user_data)
  user_data = templatefile("${abspath(path.cwd)}/modules/lb/templates/user-data.sh", {})
  tags      = local.tags
}

# Application Load Balancer
resource "aws_lb_target_group" "lb_target" {
  name        = "lb-target"
  port        = "80"
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.lb_sg.security_group_id]
  subnets            = var.public_subnet_id
  # subnets                    = element(var.public_subnet_id, 0)
  enable_deletion_protection = false
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target.arn
  }
}

# Supporting Resources
# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = var.vpc_name
#   cidr = "10.99.0.0/18"

#   azs                  = ["${var.region}a", "${var.region}b", "${var.region}c"]
#   public_subnets       = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
#   private_subnets      = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
#   enable_dns_hostnames = true
#   enable_dns_support   = true

#   tags = local.tags
# }

# Create the security groups
module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = var.asg_name
  description = "A security group"
  vpc_id      = var.vpc_id
  # vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["10.10.0.0/16"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

module "lb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name                = var.lb_name
  description         = "A security group"
  vpc_id              = var.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

# # Create Internet Gateway
# resource "aws_internet_gateway" "igw" {
#   vpc_id = module.vpc.vpc_id
# }

# # Create Route Table for Public Subnet
# resource "aws_route_table" "rt" {
#   vpc_id = module.vpc.vpc_id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
#   tags = {
#     Name = var.route_name[0]
#   }
# }
# resource "aws_route_table_association" "rt_associate_public" {
#   subnet_id      = module.vpc.public_subnets
#   route_table_id = aws_route_table.rt.id
# }

# # Create EIP
# resource "aws_eip" "eip" {
#   vpc = true
# }

# # Create NAT Gateway
# resource "aws_nat_gateway" "gw" {
#   allocation_id = aws_eip.eip.id
#   subnet_id     = module.vpc.public_subnets
# }

# # Create Route Table for NAT Gateway
# resource "aws_route_table" "rt_NAT" {
#   vpc_id = module.vpc.vpc_id
#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.gw.id
#   }
#   tags = {
#     Name = var.route_name[1]
#   }
# }
# resource "aws_route_table_association" "rt_associate_private" {
#   subnet_id      = module.vpc.private_subnets
#   route_table_id = aws_route_table.rt_NAT.id
# }
