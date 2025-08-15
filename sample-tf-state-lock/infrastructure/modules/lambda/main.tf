# Reference the manually created IAM role
# The role should be created manually in the AWS Console before running Terraform
data "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name
}

# Create ZIP file for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.lambda_source_path
  output_path = "${path.module}/lambda_function.zip"
}

# Create Lambda function
resource "aws_lambda_function" "timestamp_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.function_name}-${var.environment}"
  role            = data.aws_iam_role.lambda_role.arn
  handler         = "timestamp_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = var.runtime
  timeout         = var.timeout

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
      ENVIRONMENT = var.environment
    }
  }

  # No dependencies needed since we're using an existing role

  tags = {
    Environment = var.environment
    Component   = "lambda"
  }
}

# Create CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.timestamp_lambda.function_name}"
  retention_in_days = var.log_retention_days

  tags = {
    Environment = var.environment
    Component   = "lambda"
  }
}