# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
  
  # S3 Backend Configuration for Remote State with DynamoDB Locking
  # IMPORTANT: Deploy the CloudFormation stack first using terraform-state-simple.yaml
  # See INSTRUCTIONS-STATE-MGMT-SIMPLE.md for setup instructions
  backend "s3" {
    # Replace these values with your actual bucket and table names from CloudFormation output
    # Example values - update these after deploying the state backend:
    bucket         = "cloudguru-terraform-state-767398100921"
    key            = "sample-tf-state-lock/dev/terraform.tfstate"
    encrypt        = false
    dynamodb_table = "cloudguru-terraform-state-767398100921-lock"
    
    # Region is required for backend configuration (cannot be inferred from provider)
    region = "us-east-1"
  }
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