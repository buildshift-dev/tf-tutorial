#!/bin/bash

# Lambda testing script
# Usage: ./scripts/test-lambda.sh [environment]
# Example: ./scripts/test-lambda.sh dev

set -e

ENVIRONMENT=${1:-dev}
TERRAFORM_DIR="infrastructure/environments/${ENVIRONMENT}"

echo "=== Testing Lambda function in ${ENVIRONMENT} environment ==="

# Change to Terraform directory to get outputs
cd "$TERRAFORM_DIR"

# Get function name from Terraform output
FUNCTION_NAME=$(terraform output -raw lambda_function_name 2>/dev/null || echo "")
BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")

if [ -z "$FUNCTION_NAME" ]; then
    echo "Error: Could not retrieve Lambda function name. Make sure Terraform has been applied."
    exit 1
fi

if [ -z "$BUCKET_NAME" ]; then
    echo "Error: Could not retrieve S3 bucket name. Make sure Terraform has been applied."
    exit 1
fi

echo "Lambda Function: $FUNCTION_NAME"
echo "S3 Bucket: $BUCKET_NAME"
echo ""

# Go back to root directory for response files
cd ../../..

# Test 1: Simple invocation
echo "=== Test 1: Simple invocation ==="
aws lambda invoke \
    --function-name "$FUNCTION_NAME" \
    --payload '{}' \
    response1.json

echo "Response:"
cat response1.json | jq .
echo ""

# Test 2: Invocation with test data
echo "=== Test 2: Invocation with test data ==="
aws lambda invoke \
    --function-name "$FUNCTION_NAME" \
    --payload '{"test_id": "test-001", "message": "Hello from test script"}' \
    response2.json

echo "Response:"
cat response2.json | jq .
echo ""

# Test 3: Multiple invocations
echo "=== Test 3: Multiple invocations (5 times) ==="
for i in {1..5}; do
    echo "Invocation $i..."
    aws lambda invoke \
        --function-name "$FUNCTION_NAME" \
        --payload "{\"test_run\": $i, \"batch\": \"multiple-test\"}" \
        "response_batch_$i.json" > /dev/null
    sleep 1
done
echo "Multiple invocations completed."
echo ""

# List files in S3
echo "=== Files created in S3 bucket ==="
aws s3 ls "s3://$BUCKET_NAME/" --recursive

echo ""
echo "=== Testing completed ==="
echo "Clean up response files with: rm response*.json"