# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Create S3 bucket module
module "s3_bucket" {
  source = "../../modules/s3"
  
  bucket_name = var.bucket_name
  environment = var.environment
}

# Create Lambda function module
module "lambda_function" {
  source = "../../modules/lambda"
  
  function_name        = var.lambda_function_name
  bucket_name          = module.s3_bucket.bucket_name
  bucket_arn           = module.s3_bucket.bucket_arn
  environment          = var.environment
  lambda_source_path   = var.lambda_source_path
  lambda_role_name     = var.lambda_role_name
}