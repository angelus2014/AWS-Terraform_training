resource "aws_s3_bucket" "prod_am" {
  bucket_prefix = var.bucket_prefix

  #   website {
  #     index_document = "index.html"
  #     error_document = "error.html"
  #   }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.prod_am.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "prod_am" {
  bucket = aws_s3_bucket.prod_am.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.prod_am.id}/*"
            ]
        }
    ]
}
POLICY
}
