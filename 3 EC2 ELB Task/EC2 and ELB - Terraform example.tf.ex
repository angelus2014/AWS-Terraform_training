# Grab the latest Cisco Hardened jumphost AmazonLinux2 AMI ID
data "aws_ami" "cisco_hardened_amazonlinux2" {
  most_recent = true
  owners      = ["352039262102"]
  filter {
    name   = "name"
    values = ["CiscoHardened-AmazonLinux2_HVM_EBS*"]
  }
}

# CMK for EBS volume encryption
resource "aws_kms_key" "ipb_kms_key" {
  description         = "KMS key for the ipb's EBS volume encryption"
  enable_key_rotation = true

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                    "arn:aws:iam::${var.aws_account}:root",
                    "arn:aws:iam::${var.aws_account}:role/cross-account-role",
                    "arn:aws:iam::${var.aws_account}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
                ]
            },
            "Action": "kms:*",
            "Resource": "*"
        }
    ]
}
EOF

  tags = merge(var.cisco_tags, tomap({ "Name" = "ipb-kms-key" }))
}

resource "aws_kms_alias" "ipb_kms_key" {
  name          = "alias/ipb-ipsec-monitor"
  target_key_id = aws_kms_key.ipb_kms_key.key_id
}

# KEY PAIR
module "key_pair" {
  source     = "terraform-aws-modules/key-pair/aws"
  version    = "v1.0.0"
  key_name   = "${terraform.workspace}-${var.key_pair}"
  public_key = var.public_key

  tags = merge(var.cisco_tags, tomap({ "Name" = "${terraform.workspace}_ipb_key" }))
}

# ASG EC2 for ECS
data "cloudinit_config" "ecs_ec2" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.user_data.rendered
  }
}

data "template_file" "user_data" {
  template = file("${path.root}/templates/user_data.tpl")

  vars = {
    env = "${terraform.workspace}"
  }
}

resource "aws_launch_template" "ecs_launch_template" {
  image_id = data.aws_ami.cisco_hardened_amazonlinux2.id

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    subnet_id                   = var.ipb_subnets[0]
    security_groups             = [aws_security_group.ipb_sg.id]
  }
  user_data     = base64encode(data.cloudinit_config.ecs_ec2.rendered)
  key_name      = module.key_pair.key_pair_key_name
  instance_type = var.instance_type

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      encrypted             = true
      kms_key_id            = aws_kms_key.ipb_kms_key.arn
      volume_size           = var.volume_size
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.cisco_tags, tomap({ "Name" = "${var.ec2_name}-${terraform.workspace}" }))
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(var.cisco_tags, tomap({ "Name" = "${var.ec2_name}-${terraform.workspace}" }))
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.cisco_tags, tomap({ "Name" = "ecs-launch-template" }))
}

locals {
  cisco_tags = [
    for k, v in var.cisco_tags : {
      key                 = k
      value               = v
      propagate_at_launch = true
    }
  ]
}

resource "aws_autoscaling_group" "ecs_asg" {
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = aws_launch_template.ecs_launch_template.latest_version
  }
  desired_capacity          = var.asg_desired_capacity
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  health_check_grace_period = 300
  health_check_type         = "EC2"

  lifecycle {
    create_before_destroy = true
  }
  tags = local.cisco_tags
}

# ALB
resource "aws_lb_target_group" "locust_master" {
  name        = "locust-master"
  port        = 8089
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = local.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_lb" "locust_master" {
  name               = "locust-master"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = local.subnet_ids

  enable_deletion_protection = false
}

resource "aws_lb_listener" "locust_master" {
  load_balancer_arn = aws_lb.locust_master.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.locust_master.arn
  }
}

