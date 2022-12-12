# Create the S3 bucket
module "s3" {
  source = "./modules/s3-replication"
  # bucket_prefix = "this-is-only-a-test-bucket-delete-me-"
}
