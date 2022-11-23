resource "aws_launch_configuration" "web" {
  name_prefix                 = "web-"
  image_id                    = "ami-087c17d1fe0178315"
  instance_type               = "t2.micro"
  key_name                    = "my-key"
  security_groups             = ["${aws_security_group.demosg2.id}"]
  associate_public_ip_address = true
  user_data                   = "data.sh"
  lifecycle {
    create_before_destroy = true
  }
}
