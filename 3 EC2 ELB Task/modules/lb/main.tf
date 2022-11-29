resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = file("${abspath(path.cwd)}/my-key.pub")
}

locals {
  asg_name = "am-auto-scaling-group"
  lb_name  = "am-load-balancer"
  vpc_name = "am-vpc"
  region   = "eu-north-1"
  tags = {
    Environment = "demo"
    Blog        = "auto-scaling-group-setup"
  }

  user_data = <<-EOT
  #!/bin/bash
  yum update -y
  amazon-linux-extras install -y nginx1
  systemctl start nginx
  systemctl enable nginx
  EOT
}

# Launch template
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["private"]
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${local.asg_name}-launch-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    subnet_id                   = element(module.vpc.private_subnets, 0)
    security_groups             = [module.asg_sg.security_group_id]
  }
  key_name = var.key_name
  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
module "auto-scaling-group-demo" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "external-${local.asg_name}"

  vpc_zone_identifier = module.vpc.private_subnets
  security_groups     = [module.asg_sg.security_group_id]
  min_size            = 0
  max_size            = 1
  desired_capacity    = 1

  create_launch_template = false
  launch_template        = aws_launch_template.this.name
  user_data              = base64encode(local.user_data)

  tags = local.tags
}

# Application Load Balancer
resource "aws_lb_target_group" "lb_target" {
  name        = "lb-target"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.lb_sg.security_group_id]
  subnets            = module.vpc.public_subnets

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
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.vpc_name
  cidr = "10.99.0.0/18"

  azs                  = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets       = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets      = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name                = local.asg_name
  description         = "A security group"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["10.99.0.0/18"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

module "lb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name                = local.lb_name
  description         = "A security group"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}
