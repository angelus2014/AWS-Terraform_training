# Create the S3 bucket resources
resource "aws_s3_bucket" "tf_am_s3" {
  bucket = var.s3_bucket_name
  tags = {
    Name = var.s3_friendly_name
  }
}

resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.tf_am_s3.id
  acl    = "private"
}

resource "aws_dynamodb_table" "dynamodb-terraform-state-lock" {
  name           = "terraform-state-lock-dynamo-tfams3bucket"
  hash_key       = "LockID"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = "LockID"
    type = "S"
  }
}
