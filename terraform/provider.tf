terraform {
  # Backend Configuration
  #   backend "s3" {
  #     # S3 Bucket Configuration
  #     bucket = "terraform-state-file"
  #     key    = "tfstate/coresvc/terraform.tfstate"
  #     region = "ap-southeast-1"

  #     # DynamoDB Configuration
  #     dynamodb_table = "terraform-locks"
  #     encrypt        = true
  #   }

  backend "local" {
    path = "terraform.tfstate"
  }

  # Providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.49"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = local.region
}