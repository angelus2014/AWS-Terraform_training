provider "aws" {
  region = local.region

  default_tags {
    tags = {
      Project = "auto-scaling-group-demo"
    }
  }
}

locals {
  name   = "auto-scaling-group-basic"
  region = "us-east-1"
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


################################################################################
# Launch template
################################################################################

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

  lifecycle {
    create_before_destroy = true
  }
}



################################################################################
# Auto Scaling Group
################################################################################


module "auto-scaling-group-demo" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "external-${local.name}"

  vpc_zone_identifier = module.vpc.private_subnets
  security_groups     = [module.asg_sg.security_group_id]
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2

  create_launch_template = false
  launch_template        = aws_launch_template.this.name
  user_data              = base64encode(local.user_data)

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

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
  vpc_id      = module.vpc.vpc_id

  egress_rules = ["all-all"]

  tags = local.tags
}


# module "network_load_balancer" {
#   source  = "infrablocks/network-load-balancer/aws"
#   version = "~> 0.2.0"

#   region     = local.region
#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = public_subnets

#   # component             = "important-component"
#   # deployment_identifier = "production"

#   # domain_name     = "example.com"
#   # public_zone_id  = "Z1WA3EVJBXSQ2V"
#   # private_zone_id = "Z3CVA9QD5NHSW3"

#   listeners = [
#     {
#       lb_port            = 443
#       lb_protocol        = "HTTPS"
#       instance_port      = 443
#       instance_protocol  = "HTTPS"
#       ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/default"
#     },
#     {
#       lb_port           = 80
#       lb_protocol       = "HTTP"
#       instance_port     = 80
#       instance_protocol = "HTTP"
#     },
#     {
#       lb_port           = 6567
#       lb_protocol       = "TCP"
#       instance_port     = 6567
#       instance_protocol = "TCP"
#     }
#   ]

#   access_control = [
#     {
#       lb_port       = 443
#       instance_port = 443
#       allow_cidr    = "0.0.0.0/0"
#     },
#     {
#       lb_port       = 80
#       instance_port = 80
#       allow_cidr    = "0.0.0.0/0"
#     },
#     {
#       lb_port       = 6567
#       instance_port = 6567
#       allow_cidr    = "0.0.0.0/0"
#     }
#   ]

#   egress_cidrs = "0.0.0.0/0"

#   health_check_target              = "HTTPS:443/ping"
#   health_check_timeout             = 10
#   health_check_interval            = 30
#   health_check_unhealthy_threshold = 5
#   health_check_healthy_threshold   = 5

#   enable_cross_zone_load_balancing = "yes"

#   enable_connection_draining  = "yes"
#   connection_draining_timeout = 60

#   idle_timeout = 60

#   include_public_dns_record  = "yes"
#   include_private_dns_record = "yes"

#   expose_to_public_internet = "yes"
# }

# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "~> 8.0"

#   name = "my-alb"

#   load_balancer_type = "application"

#   vpc_id             = module.vpc.vpc_id
#   subnets            = public_subnets
#   security_groups    = ["sg-edcd9784", "sg-edcd9785"]

#   # access_logs = {
#   #   bucket = "my-alb-logs"
#   # }

#   target_groups = [
#     {
#       name_prefix      = "pref-"
#       backend_protocol = "HTTP"
#       backend_port     = 80
#       target_type      = "instance"
#       targets = {
#         my_target = {
#           target_id = "i-0123456789abcdefg"
#           port = 80
#         }
#         my_other_target = {
#           target_id = "i-a1b2c3d4e5f6g7h8i"
#           port = 8080
#         }
#       }
#     }
#   ]

#   https_listeners = [
#     {
#       port               = 443
#       protocol           = "HTTPS"
#       certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
#       target_group_index = 0
#     }
#   ]

#   http_tcp_listeners = [
#     {
#       port               = 80
#       protocol           = "HTTP"
#       target_group_index = 0
#     }
#   ]

#   tags = {
#     Environment = "Test"
#   }
# }

module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "my-nlb"

  load_balancer_type = "network"

  vpc_id  = module.vpc.vpc_id
  subnets = ["subnet-0d239f67e8c015018", "subnet-0b170a4507d95b19c", "subnet-0d0a24c09ae1f9e48"]

  # access_logs = {
  #   bucket = "my-nlb-logs"
  # }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "TCP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "TLS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "TCP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "Test"
  }
}
