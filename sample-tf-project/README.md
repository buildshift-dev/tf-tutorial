# Terraform AWS Lambda and S3 Tutorial

This tutorial demonstrates how to use Terraform to create an AWS Lambda function that generates timestamp files and stores them in an S3 bucket. This project follows Terraform best practices with a modular structure and is designed to work in AWS Cloud9 with Amazon Linux 2023.

## Project Overview

Each time the Lambda function is executed, it creates a JSON file in S3 containing:
- Execution timestamp
- Environment information
- Lambda function metadata
- Request context information

## File Structure

```
sample-tf-project/
├── infrastructure/
│   ├── environments/
│   │   └── dev/
│   │       ├── main.tf           # Environment-specific configuration
│   │       ├── variables.tf      # Environment variables
│   │       └── outputs.tf        # Environment outputs
│   └── modules/
│       ├── lambda/
│       │   ├── main.tf           # Lambda module
│       │   ├── variables.tf      # Lambda variables
│       │   └── outputs.tf        # Lambda outputs
│       └── s3/
│           ├── main.tf           # S3 module
│           ├── variables.tf      # S3 variables
│           └── outputs.tf        # S3 outputs
├── src/
│   └── lambda/
│       ├── timestamp_function.py # Python Lambda function code
│       └── requirements.txt      # Python dependencies
├── scripts/
│   ├── deploy.sh                 # Deployment script
│   └── test-lambda.sh           # Testing script
├── .gitignore                   # Git ignore file
└── README.md                    # This tutorial
```

### Directory Structure Explained

- **`infrastructure/`**: All Terraform code
  - **`environments/`**: Environment-specific configurations (dev, staging, prod)
  - **`modules/`**: Reusable Terraform modules
- **`src/`**: Application source code
  - **`lambda/`**: Lambda function code and dependencies
- **`scripts/`**: Automation and utility scripts

## Prerequisites

1. **AWS Cloud9 Environment** with Amazon Linux 2023
2. **AWS CLI** configured with appropriate permissions
3. **Terraform** installed
4. **AWS IAM Role created manually** in AWS Console (see Step 1 below)

### Easy Setup with Our Script

For **AWS Cloud9** with Amazon Linux 2023, use our automated setup script:

```bash
# From the repository root (tf-tutorial/)
chmod +x setup-cloud9.sh
./setup-cloud9.sh

# Reload your shell to use new aliases
source ~/.bashrc

# Verify installations
python --version    # Should show Python 3.11.x
terraform --version # Should show Terraform v1.7.0
```

### Manual Installation (Alternative)

If you prefer manual installation:

```bash
# Update system and install Python 3.11
sudo yum update -y
sudo yum install -y python3.11 python3.11-pip

# Set up Python aliases
echo "alias python=python3.11" >> ~/.bashrc
echo "alias pip=pip3.11" >> ~/.bashrc
source ~/.bashrc

# Download and install Terraform
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.7.0_linux_amd64.zip
terraform --version
```

## AWS Permissions Required

Your Cloud9 environment needs the following AWS permissions:
- `s3:CreateBucket`, `s3:PutObject`, `s3:GetObject`, `s3:ListBucket`
- `lambda:CreateFunction`, `lambda:InvokeFunction`, `lambda:UpdateFunctionCode`
- `iam:PassRole` (to use existing IAM roles)
- `logs:CreateLogGroup`, `logs:PutLogEvents`

## Deployment Steps

### 1. Create IAM Role

**IMPORTANT**: You must create the Lambda execution role before running Terraform. Choose one of these methods:

#### Option A: Using CloudFormation (Recommended)

Use the provided CloudFormation template to create the role:

```bash
# Navigate to the tutorial root directory (tf-tutorial/)
cd ..

# Deploy the IAM role using CloudFormation
aws cloudformation create-stack \
  --stack-name terraform-lambda-role \
  --template-body file://iam-role-cloudformation.yaml \
  --capabilities CAPABILITY_NAMED_IAM

# Wait for the stack to complete
aws cloudformation wait stack-create-complete --stack-name terraform-lambda-role

# Verify the role was created
aws cloudformation describe-stacks --stack-name terraform-lambda-role --query 'Stacks[0].Outputs'

# Go back to the project directory
cd sample-tf-project
```

#### Option B: Manual Creation in AWS Console

1. Go to **AWS Console > IAM > Roles**
2. Click **"Create role"**
3. Select **"AWS service"** → **"Lambda"**
4. Click **"Next"**
5. Add these permissions:
   - **AWSLambdaBasicExecutionRole** (for CloudWatch logs)
   - **AmazonS3FullAccess** (for S3 operations)
6. Click **"Next"**
7. **Role name**: `TerraformLambdaRole`
8. Click **"Create role"**

**Note**: The role name `TerraformLambdaRole` is used by default in the Terraform configuration. You can change this by modifying the `lambda_role_name` variable.

### 2. Clone or Download the Project

```bash
# In your Cloud9 terminal, create the project directory
mkdir sample-tf-project
cd sample-tf-project

# Copy all the files from this tutorial into the directory
```

### 3. Quick Start with Scripts

The easiest way to deploy is using the provided scripts:

```bash
# Make scripts executable (if needed)
chmod +x scripts/*.sh

# Initialize Terraform
./scripts/deploy.sh dev init

# Plan the deployment
./scripts/deploy.sh dev plan

# Apply the deployment
./scripts/deploy.sh dev apply
```

### 4. Manual Deployment (Alternative)

If you prefer manual control:

```bash
# Navigate to the dev environment
cd infrastructure/environments/dev

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the deployment
terraform apply
```

### 5. Customize Variables (Optional)

Create environment-specific variables:

```bash
# Create terraform.tfvars in infrastructure/environments/dev/
cat > infrastructure/environments/dev/terraform.tfvars << EOF
aws_region = "us-west-2"
bucket_name = "my-unique-timestamp-bucket-$(date +%s)"
lambda_function_name = "my-timestamp-function"
environment = "dev"
lambda_role_name = "TerraformLambdaRole"
EOF
```

**Important**: S3 bucket names must be globally unique. The template adds the environment suffix automatically.

### 6. Verify Deployment

Check the outputs:

```bash
# Using the script
./scripts/deploy.sh dev output

# Or manually
cd infrastructure/environments/dev && terraform output
```

You should see:
- S3 bucket name and ARN
- Lambda function name and ARN
- IAM role ARN
- Environment and region information

## Testing the Lambda Function

### Method 1: Using the Test Script (Recommended)

The easiest way to test is using the provided test script:

```bash
# Test the Lambda function
./scripts/test-lambda.sh dev
```

This script will:
- Perform multiple test invocations
- Display responses
- Show files created in S3
- Clean up instructions

### Method 2: Manual AWS CLI Testing

```bash
# Navigate to the terraform directory to get outputs
cd infrastructure/environments/dev

# Get the function name from terraform output
FUNCTION_NAME=$(terraform output -raw lambda_function_name)
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Go back to root directory
cd ../../..

# Invoke the Lambda function with empty payload
aws lambda invoke --function-name $FUNCTION_NAME --payload '{}' response.json

# Check the response
cat response.json | jq .

# Alternative: Invoke with custom payload (use file method to avoid base64 errors)
echo '{"test": "Hello World!"}' > payload.json
aws lambda invoke --function-name $FUNCTION_NAME --payload file://payload.json response.json
cat response.json | jq .

# Verify file was created in S3
aws s3 ls s3://$BUCKET_NAME/ --recursive
```

### Method 3: AWS Console Testing

1. Go to AWS Lambda Console
2. Find your function (default: `timestamp-creator-dev`)
3. Click "Test" tab
4. Create a test event with empty JSON: `{}`
5. Execute the test
6. Check S3 Console for the created file under the `dev/` prefix

### Method 4: Multiple Test Executions

```bash
# Get function and bucket names
cd infrastructure/environments/dev
FUNCTION_NAME=$(terraform output -raw lambda_function_name)
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
cd ../../..

# Create multiple timestamp files
for i in {1..5}; do
  echo "{\"test_run\": $i}" > payload_$i.json
  aws lambda invoke --function-name $FUNCTION_NAME --payload file://payload_$i.json response_$i.json
  sleep 2
done

# List all created files
aws s3 ls s3://$BUCKET_NAME/dev/ --recursive
```

## Understanding the Lambda Function

The Python function (`src/lambda/timestamp_function.py`) does the following:

1. **Gets environment variables**: Reads the S3 bucket name and environment
2. **Generates timestamp**: Creates a unique timestamp for the filename
3. **Collects metadata**: Gathers Lambda context and event information
4. **Creates JSON content**: Formats all data as JSON with enhanced metadata
5. **Uploads to S3**: Stores the file with environment prefix and timestamp-based name

### Sample Output File Content

```json
{
  "execution_time": "2024-01-15T10:30:45.123456",
  "environment": "dev",
  "lambda_request_id": "12345678-1234-1234-1234-123456789012",
  "lambda_function_name": "timestamp-creator-dev",
  "lambda_function_version": "$LATEST",
  "remaining_time_ms": 299985,
  "memory_limit_mb": 128,
  "log_group_name": "/aws/lambda/timestamp-creator-dev",
  "log_stream_name": "2024/01/15/[$LATEST]abcdef123456",
  "event_data": {},
  "metadata": {
    "region": "us-east-1",
    "runtime": "python3.11",
    "architecture": "x86_64"
  }
}
```

### Key Improvements in the Modular Version

- **Environment separation**: Files are organized by environment (dev/, staging/, prod/)
- **Enhanced metadata**: More comprehensive information collection
- **Better resource naming**: Resources include environment suffix
- **Improved security**: Server-side encryption and lifecycle policies

## Terraform Commands Reference

### Using the Deploy Script (Recommended)

```bash
# Initialize Terraform
./scripts/deploy.sh dev init

# Validate and format code
./scripts/deploy.sh dev validate
./scripts/deploy.sh dev fmt

# Plan changes
./scripts/deploy.sh dev plan

# Apply changes
./scripts/deploy.sh dev apply

# Show outputs
./scripts/deploy.sh dev output

# Destroy all resources
./scripts/deploy.sh dev destroy
```

### Manual Commands (from infrastructure/environments/dev/)

```bash
# Navigate to environment directory
cd infrastructure/environments/dev

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Plan changes
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List resources
terraform state list

# Show outputs
terraform output

# Destroy all resources
terraform destroy
```

## Monitoring and Logs

### View Lambda Logs

```bash
# Get recent logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/"

# View specific log stream
aws logs describe-log-streams --log-group-name "/aws/lambda/timestamp-creator" --order-by LastEventTime --descending
```

### Check S3 Contents

```bash
# List all timestamp files
aws s3 ls s3://$(terraform output -raw s3_bucket_name)/ --recursive

# Download a specific file
aws s3 cp s3://$(terraform output -raw s3_bucket_name)/timestamp_2024-01-15_10-30-45-123.txt ./
```

## Troubleshooting

### Common Issues

1. **Bucket name already exists**: Add a unique suffix to the bucket name
2. **Permission denied**: Ensure your AWS credentials have sufficient permissions
3. **Lambda timeout**: Check CloudWatch logs for execution details
4. **S3 upload fails**: Verify IAM policies and bucket permissions

### Useful Debugging Commands

```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify Terraform state
terraform state show aws_lambda_function.timestamp_lambda

# Test Lambda function locally (if needed)
python3 lambda_function.py
```

## Multi-Environment Setup

This structure supports multiple environments. To create staging and production environments:

```bash
# Create staging environment
cp -r infrastructure/environments/dev infrastructure/environments/staging

# Create production environment  
cp -r infrastructure/environments/dev infrastructure/environments/prod

# Deploy to staging
./scripts/deploy.sh staging init
./scripts/deploy.sh staging apply

# Deploy to production
./scripts/deploy.sh prod init
./scripts/deploy.sh prod apply
```

Edit the `terraform.tfvars` files in each environment directory to customize settings.

## Terraform Best Practices Implemented

1. **Modular Structure**: Reusable modules for Lambda and S3
2. **Environment Separation**: Isolated state files and configurations
3. **Resource Tagging**: Consistent tagging strategy
4. **Variable Validation**: Input validation for bucket names
5. **Output Values**: Important information exposed via outputs
6. **Security**: IAM least privilege, S3 encryption, public access blocking
7. **Lifecycle Management**: S3 lifecycle policies for cost optimization

## Cleanup

To remove all created resources:

```bash
# Using the script
./scripts/deploy.sh dev destroy

# Or manually
cd infrastructure/environments/dev && terraform destroy
```

Type `yes` when prompted. This will delete:
- Lambda function
- S3 bucket and all files
- CloudWatch log groups

**Note**: The manually created IAM role (`TerraformLambdaRole`) will NOT be deleted by Terraform since it was created outside of Terraform. 

If you used CloudFormation to create the role, you can delete it with:
```bash
aws cloudformation delete-stack --stack-name terraform-lambda-role
```

Or delete it manually in the AWS Console if needed.

## Next Steps

Consider extending this tutorial by:
1. **API Gateway Integration**: Add HTTP triggers for the Lambda
2. **EventBridge Scheduling**: Set up scheduled execution
3. **Multiple Environments**: Deploy staging and production environments
4. **Monitoring**: Add CloudWatch alarms and dashboards
5. **CI/CD Pipeline**: Integrate with GitHub Actions or AWS CodePipeline
6. **Testing**: Add unit tests for Lambda function
7. **Error Handling**: Implement retry logic and dead letter queues

## Security Best Practices Implemented

- **S3 Security**: Public access blocked, server-side encryption enabled
- **IAM Security**: Least privilege roles and policies
- **Resource Isolation**: Environment-specific resources and naming
- **Logging**: Comprehensive CloudWatch logging
- **State Management**: Secure Terraform state handling