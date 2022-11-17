# Create the overall vpc
module "vpc" {
  source = "./modules/vpc"
}

# Create the networking components: subnets, routing, gateways
module "network" {
  source = "./modules/network"

  vpc_id = module.vpc.vpc_id
}

# Create the ec2 components: EC2, Routing Table
module "ec2" {
  source = "./modules/ec2"

  vpc_id     = module.vpc.vpc_id
  subnet_id1 = module.network.subnet_id1
  subnet_id2 = module.network.subnet_id2
}

# # Create the S3 bucket resources
# resource "aws_s3_bucket" "tf_am_s3" {
#   bucket = var.s3_bucket_name
#   tags = {
#     Name = var.s3_friendly_name
#   }
# }

# resource "aws_s3_bucket_acl" "s3_bucket_acl" {
#   bucket = aws_s3_bucket.tf_am_s3.id
#   acl    = "private"
# }

# resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
#   name           = "terraform-state-lock-dynamo-tfams3bucket"
#   hash_key       = "LockID"
#   read_capacity  = 20
#   write_capacity = 20

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
