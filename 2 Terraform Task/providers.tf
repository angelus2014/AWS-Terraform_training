terraform {

  # backend "s3" {
  #   encrypt        = true
  #   bucket         = "tfams3bucket"
  #   dynamodb_table = "terraform-state-lock-dynamo-tfams3bucket"
  #   key            = "terraform.tfstate"
  #   region         = "eu-north-1"
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "eu-north-1"
  profile = "default"
}
