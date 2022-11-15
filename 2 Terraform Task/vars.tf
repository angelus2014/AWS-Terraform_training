# Define the global S3 bucket name
variable "s3_bucket_name" {
  type    = string
  default = "tfams3bucket"
}

# Define the 'friendly' S3 bucket name
variable "s3_friendly_name" {
  type    = string
  default = "S3Bucket"
}

# # Define the DynamoDB name
# variable "dynamodb_name" {
#   type    = string
#   default = "terraform-state-lock_dynamo"
# }
