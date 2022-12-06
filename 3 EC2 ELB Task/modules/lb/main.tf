# Define my SSH key to be used for the EC2 instances
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

resource "aws_launch_template" "this" {
  name_prefix   = "${var.asg_name}-launch-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    subnet_id                   = element(var.private_subnet_id, 0)
    security_groups             = [module.asg_sg.security_group_id]
  }
  key_name = var.key_name
  lifecycle {
    create_before_destroy = true
  }
  user_data = filebase64("${path.module}/templates/user-data.sh")
}

# Auto Scaling Group
resource "aws_autoscaling_group" "demo" {

  name = "external-${var.asg_name}"

  vpc_zone_identifier = var.private_subnet_id
  min_size            = 0
  max_size            = 1
  desired_capacity    = 1

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}


# Application Load Balancer
resource "aws_lb_target_group" "lb_target" {
  name        = "lb-target"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_lb" "app_lb" {
  name                       = "app-lb"
  load_balancer_type         = "application"
  security_groups            = [module.lb_sg.security_group_id]
  subnets                    = var.public_subnet_id
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

# Connect the LB to the ASG
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.demo.id
  lb_target_group_arn    = aws_lb_target_group.lb_target.id
}

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
