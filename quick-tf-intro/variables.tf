# Variables allow us to customize our Terraform configuration
# Think of them like settings you can change without editing the main code

# AWS Region - where our resources will be created
# You can change this to any AWS region like "us-west-2", "eu-west-1", etc.
variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

# S3 Bucket Name - must be globally unique across all of AWS
# That's why we include a random suffix in the default
variable "bucket_name" {
  description = "Name for the S3 bucket (must be globally unique)"
  type        = string
  default     = "my-timestamp-bucket-12345"
  
  # This validation makes sure the bucket name follows AWS rules
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be lowercase, contain only letters, numbers, and hyphens, and not start or end with a hyphen."
  }
}

# Lambda Function Name
variable "lambda_function_name" {
  description = "Name for the Lambda function"
  type        = string
  default     = "timestamp-creator"
}

# Lambda IAM Role Name (manually created)
variable "lambda_role_name" {
  description = "Name of the manually created IAM role for Lambda"
  type        = string
  default     = "TerraformLambdaRole"
}