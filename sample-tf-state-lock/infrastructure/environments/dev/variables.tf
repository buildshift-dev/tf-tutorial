# Environment
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# AWS Region
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# S3 Bucket Name
variable "bucket_name" {
  description = "Name of the S3 bucket for storing timestamp files"
  type        = string
  default     = "timestamp-files-bucket"
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be lowercase, contain only letters, numbers, and hyphens, and not start or end with a hyphen."
  }
}

# Lambda Function Name
variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "timestamp-creator"
}

# Lambda Source Path
variable "lambda_source_path" {
  description = "Path to the Lambda function source code"
  type        = string
  default     = "../../../src/lambda/timestamp_function.py"
}

# Lambda IAM Role Name (manually created)
variable "lambda_role_name" {
  description = "Name of the manually created IAM role for Lambda"
  type        = string
  default     = "TerraformLambdaRole"
}