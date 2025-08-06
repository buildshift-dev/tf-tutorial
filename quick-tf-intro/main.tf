# This is the main Terraform configuration file
# Everything needed for our AWS Lambda + S3 setup is defined here

# Configure the AWS Provider
# This tells Terraform to use the AWS provider and which version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

# Configure AWS Provider settings
# This sets up our connection to AWS
provider "aws" {
  region = var.aws_region
}

# Create an S3 bucket to store our timestamp files
# S3 is like a file storage service in the cloud
resource "aws_s3_bucket" "timestamp_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = "Timestamp Files Bucket"
    Environment = "Tutorial"
  }
}

# Configure S3 bucket versioning
# This keeps old versions of files when they're updated
resource "aws_s3_bucket_versioning" "timestamp_bucket_versioning" {
  bucket = aws_s3_bucket.timestamp_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access to the S3 bucket
# This makes sure random people on the internet can't see our files
resource "aws_s3_bucket_public_access_block" "timestamp_bucket_pab" {
  bucket = aws_s3_bucket.timestamp_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Reference the manually created IAM role
# You'll create this role manually in the AWS Console before running Terraform
data "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
}

# Create a ZIP file containing our Python code
# Lambda needs code to be packaged as a ZIP file
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# Create our Lambda function
# This is the actual serverless function that will run our code
resource "aws_lambda_function" "timestamp_lambda" {
  filename         = "lambda_function.zip"
  function_name    = var.lambda_function_name
  role            = data.aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.11"
  timeout         = 30

  # Environment variables that our Python code can access
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.timestamp_bucket.bucket
    }
  }

  # No dependencies needed since we're using an existing role

  tags = {
    Name = "Timestamp Creator Function"
  }
}

# Create a CloudWatch Log Group for our Lambda function
# This is where we can see the output and debug info from our function
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.timestamp_lambda.function_name}"
  retention_in_days = 14

  tags = {
    Name = "Lambda Logs"
  }
}

# ================================
# OPTIONAL: EC2 Instance Example
# ================================
# Uncomment the resource below to add a small EC2 instance to your infrastructure
# This demonstrates how easy it is to add new resources to existing Terraform projects
#
# resource "aws_instance" "example_ec2" {
#   ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2023 AMI (us-east-1)
#   instance_type = "t2.micro"               # Free tier eligible
# 
#   tags = {
#     Name        = "Example EC2 Instance"
#     Environment = "Tutorial"
#   }
# }
#
# Note: In Cloud Guru environments, you cannot create new IAM roles via CLI/Terraform
# This EC2 instance will use the default instance profile if available
# For a production setup, you would typically create a custom IAM role for EC2