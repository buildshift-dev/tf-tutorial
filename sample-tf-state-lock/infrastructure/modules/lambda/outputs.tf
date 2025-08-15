output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.timestamp_lambda.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.timestamp_lambda.arn
}

output "role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = data.aws_iam_role.lambda_role.arn
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.timestamp_lambda.invoke_arn
}