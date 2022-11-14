terraform {

  backend "s3" {
    encrypt        = true
    bucket         = "am_s3_bucket"
    dynamodb_table = "terraform-state-lock-dynamo-am_s3_bucket"
    key            = "terraform.tfstate"
    region         = "eu-north-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}
