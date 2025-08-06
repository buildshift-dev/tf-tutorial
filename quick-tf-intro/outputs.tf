# Outputs show us important information after Terraform creates our resources
# This is useful for getting the names and IDs of things we just created

# Display the S3 bucket name
# We'll need this to see where our files are stored
output "s3_bucket_name" {
  description = "The name of the S3 bucket where timestamp files are stored"
  value       = aws_s3_bucket.timestamp_bucket.bucket
}

# Display the S3 bucket ARN (Amazon Resource Name)
# ARNs are unique identifiers for AWS resources
output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.timestamp_bucket.arn
}

# Display the Lambda function name
# We'll use this to test our function
output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.timestamp_lambda.function_name
}

# Display the Lambda function ARN
output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.timestamp_lambda.arn
}

# Display the IAM role ARN
# This shows the permissions role we're using for Lambda
output "lambda_role_arn" {
  description = "The ARN of the IAM role used by Lambda"
  value       = data.aws_iam_role.lambda_role.arn
}

# Display the AWS region we're using
output "aws_region" {
  description = "The AWS region where resources were created"
  value       = var.aws_region
}

# Display EC2 instance information (only when uncommented in main.tf)
# output "ec2_instance_id" {
#   description = "The ID of the EC2 instance (when enabled)"
#   value       = aws_instance.example_ec2.id
# }
#
# output "ec2_public_ip" {
#   description = "The public IP of the EC2 instance (when enabled)"
#   value       = aws_instance.example_ec2.public_ip
# }