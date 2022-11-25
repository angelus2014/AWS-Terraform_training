# # Creating Security Group
# resource "aws_security_group" "sg" {
#   tags = {
#     Name = var.sg_name
#   }
#   vpc_id = var.vpc_id
#   # key_name = var.key_name

#   # Inbound Rules
#   # HTTP access from anywhere
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   # HTTPS access from anywhere
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   # SSH access from anywhere
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   # Outbound Rules
#   # Internet access to anywhere
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = file("${abspath(path.cwd)}/my-key.pub")
}

locals {
  name   = "auto-scaling-group-basic"
  region = "eu-north-1"
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

resource "aws_launch_template" "this" {
  name_prefix   = "${local.name}-launch-template"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
module "auto-scaling-group-demo" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "external-${local.name}"

  vpc_zone_identifier = module.vpc.public_subnets
  security_groups     = [module.asg_sg.security_group_id]
  min_size            = 0
  max_size            = 1
  desired_capacity    = 1

  create_launch_template = false
  launch_template        = aws_launch_template.this.name
  user_data              = base64encode(local.user_data)

  tags = local.tags
}

# Supporting Resources
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = "10.99.0.0/18"

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets  = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}

module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "A security group"
  # vpc_id      = var.
  vpc_id        = module.vpc.vpc_id
  ingress_rules = ["all-all"]
  egress_rules  = ["all-all"]

  tags = local.tags
}
