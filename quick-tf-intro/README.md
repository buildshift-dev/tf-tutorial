# Quick Terraform Intro: Lambda + S3 Tutorial

Welcome to your first Terraform project! This tutorial is designed for complete beginners who want to learn Terraform by building something real and useful.

## What You'll Learn

By the end of this tutorial, you'll understand:
- What Terraform is and why it's useful
- How to write basic Terraform configuration
- How to create AWS resources with Terraform
- How AWS Lambda and S3 work together

## What We're Building

We're creating a simple but complete system:
1. **AWS Lambda Function**: A serverless function that runs Python code
2. **S3 Bucket**: Cloud storage for files
3. **IAM Roles**: Permissions that allow Lambda to write to S3

Every time you run the Lambda function, it creates a timestamp file and saves it to S3.

## What is Terraform?

Think of Terraform as a way to describe your cloud infrastructure using code instead of clicking buttons in a web console. Instead of:
1. Logging into AWS console
2. Clicking "Create S3 bucket"
3. Filling out forms
4. Clicking "Create Lambda function"
5. Setting up permissions manually

You write code that describes what you want, and Terraform creates it all for you automatically!

## Project Structure

```
quick-tf-intro/
├── main.tf           # Main configuration (the "what" we want to create)
├── variables.tf      # Settings we can customize (the "options")
├── outputs.tf        # Information to show after creation (the "results")
├── lambda_function.py # Python code for our Lambda function
└── README.md         # This file (instructions)
```

## Prerequisites

### Required Tools

1. **AWS Cloud9 Environment** (preferred) or local machine with:
   - AWS CLI configured
   - Terraform installed
   - Python 3.11

### AWS Permissions

Your AWS user/role needs permissions to create:
- S3 buckets
- Lambda functions  
- CloudWatch log groups
- IAM: Pass existing roles to services (iam:PassRole)

**Note**: You'll create the Lambda IAM role manually in the AWS Console (instructions below)

## Easy Setup for Cloud9

### Option 1: Use the Setup Script (Recommended)

If you're using **AWS Cloud9** with Amazon Linux 2023, use our automated setup script:

```bash
# From the repository root (tf-tutorial/)
chmod +x setup-cloud9.sh
./setup-cloud9.sh

# Reload your shell
source ~/.bashrc

# Verify installations
python --version    # Should show Python 3.11.x
terraform --version # Should show Terraform v1.7.0
```

The setup script automatically installs Python 3.11, Terraform, and sets up proper aliases.

### Option 2: Manual Installation

If you prefer to install manually:

```bash
# Update system packages
sudo yum update -y

# Install Python 3.11
sudo yum install -y python3.11 python3.11-pip

# Set up aliases
echo "alias python=python3.11" >> ~/.bashrc
echo "alias pip=pip3.11" >> ~/.bashrc
source ~/.bashrc

# Download and install Terraform
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.7.0_linux_amd64.zip

# Verify installations
terraform --version
python --version
```

## Understanding the Files

### main.tf - The Heart of Our Project

This file contains **resources** - the things we want Terraform to create:

```hcl
resource "aws_s3_bucket" "timestamp_bucket" {
  bucket = var.bucket_name
}
```

This says: "Create an S3 bucket and call it 'timestamp_bucket' in our code."

### variables.tf - Our Settings

Variables let us customize things without changing the main code:

```hcl
variable "bucket_name" {
  default = "my-timestamp-bucket-12345"
}
```

Think of variables like settings in a video game - you can change them to customize your experience.

### outputs.tf - What to Show Us

After Terraform creates everything, outputs show us important information:

```hcl
output "lambda_function_name" {
  value = aws_lambda_function.timestamp_lambda.function_name
}
```

This says: "After creating the Lambda function, show me its name."

## Step-by-Step Tutorial

### Step 1: Create the Lambda IAM Role

Before running Terraform, you need to create an IAM role for Lambda. Choose one of these methods:

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
cd quick-tf-intro
```

#### Option B: Manual Creation in AWS Console

**1. Go to AWS IAM Console:**
- Open [AWS IAM Console](https://console.aws.amazon.com/iam/)
- Click **"Roles"** in the left sidebar
- Click **"Create role"**

**2. Configure the role:**
- **Trusted entity type**: AWS service
- **Use case**: Lambda
- Click **"Next"**

**3. Add permissions:**
- Search for and select: **`AWSLambdaBasicExecutionRole`**
- Search for and select: **`AmazonS3FullAccess`** (or create a custom policy for specific bucket access)
- Click **"Next"**

**4. Name the role:**
- **Role name**: `TerraformLambdaRole`
- **Description**: IAM role for Terraform Lambda tutorial
- Click **"Create role"**

**Important**: The role name must match the `lambda_role_name` variable in your Terraform configuration (default: `TerraformLambdaRole`).

### Step 2: Get the Code

```bash
# Create and enter the project directory
mkdir quick-tf-intro
cd quick-tf-intro

# Copy all the tutorial files here
```

### Step 3: Customize Your Settings (Optional)

The default settings will work, but you might want to customize:

**Option A: Edit variables.tf directly**
```bash
nano variables.tf
```

**Option B: Create a custom settings file**
```bash
cat > terraform.tfvars << EOF
bucket_name = "my-unique-bucket-$(date +%s)"
lambda_function_name = "my-timestamp-function"
lambda_role_name = "TerraformLambdaRole"
aws_region = "us-west-2"
EOF
```

**Important**: 
- S3 bucket names must be unique across ALL of AWS, not just your account
- `lambda_role_name` must match the IAM role you created in Step 1

### Step 4: Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider (the code that knows how to create AWS resources).

**What you'll see:**
- Terraform downloads plugins
- Creates a `.terraform` folder
- Shows "Terraform has been successfully initialized!"

### Step 5: See What Will Be Created

```bash
terraform plan
```

This shows you exactly what Terraform will create, without actually creating it. It's like a preview.

**What you'll see:**
- `+ aws_s3_bucket.timestamp_bucket` - Will create S3 bucket
- `+ aws_lambda_function.timestamp_lambda` - Will create Lambda function
- `+ aws_cloudwatch_log_group.lambda_log_group` - Will create log group
- Note: No IAM role creation since we're using the existing one

### Step 6: Create Everything

```bash
terraform apply
```

Type `yes` when prompted. Terraform will now create all your AWS resources!

**What happens:**
1. Creates S3 bucket with security settings
2. Packages your Python code into a ZIP file
3. Creates Lambda function using your existing IAM role
4. Sets up CloudWatch logging

### Step 7: See What Was Created

After `terraform apply` completes, you'll see output like:

```
Outputs:

lambda_function_name = "timestamp-creator"
s3_bucket_name = "my-timestamp-bucket-12345"
lambda_function_arn = "arn:aws:lambda:us-east-1:123456789012:function:timestamp-creator"
```

Copy the `lambda_function_name` - you'll need it for testing!

## Testing Your Lambda Function

### Method 1: AWS CLI (Recommended)

```bash
# Replace 'timestamp-creator' with your actual function name from the output
aws lambda invoke \
  --function-name timestamp-creator \
  --payload '{}' \
  response.json

# See the response
cat response.json
```

**What this does:**
- Calls your Lambda function
- Sends it some test data
- Saves the response to `response.json`

### Method 2: AWS Console

1. Go to [AWS Lambda Console](https://console.aws.amazon.com/lambda/)
2. Find your function (name from terraform output)
3. Click the function name
4. Click "Test" tab
5. Create a new test event:
   ```json
   {
     "message": "Hello from the console!"
   }
   ```
6. Click "Test"

### Check Your S3 Bucket

```bash
# List files in your bucket (use your bucket name from terraform output)
aws s3 ls s3://my-timestamp-bucket-12345/

# Download a file to see its contents
aws s3 cp s3://my-timestamp-bucket-12345/timestamp_2024-01-15_10-30-45-123.json ./downloaded-file.json
cat downloaded-file.json
```

### Run Multiple Tests

```bash
# Create several timestamp files
for i in {1..3}; do
  echo "Test run $i"
  aws lambda invoke \
    --function-name timestamp-creator \
    --payload "{\"test_run\": $i}" \
    response_$i.json
  sleep 2
done

# See all the files created
aws s3 ls s3://my-timestamp-bucket-12345/
```

## Understanding What Happened

### The Flow
1. **You triggered Lambda** (via AWS CLI or console)
2. **Lambda ran your Python code**
3. **Python code created a timestamp file**
4. **Python code uploaded the file to S3**
5. **Lambda returned a success message**

### The Files in S3
Each file contains JSON data like:
```json
{
  "timestamp": "2024-01-15T10:30:45.123456",
  "message": "Hello from Lambda!",
  "function_name": "timestamp-creator",
  "input_data": {"test": "Hello World!"}
}
```

## Common Beginner Issues

### 1. "Bucket name already exists"
**Problem**: S3 bucket names must be globally unique.
**Solution**: Change the `bucket_name` in `variables.tf` or create a `terraform.tfvars` file with a unique name.

### 2. "Access denied"
**Problem**: Your AWS credentials don't have the right permissions.
**Solution**: Make sure your AWS user/role can create S3, Lambda, and IAM resources.

### 3. "Terraform command not found"
**Problem**: Terraform isn't installed or not in PATH.
**Solution**: Follow the installation steps above.

## Useful Commands

### See what's in your Terraform state
```bash
terraform show
```

### See just the outputs
```bash
terraform output
```

### Format your Terraform code nicely
```bash
terraform fmt
```

### Check if your configuration is valid
```bash
terraform validate
```

### See Terraform's plan in detail
```bash
terraform plan -out=tfplan
terraform show tfplan
```

## Adding More Resources: EC2 Instance Example

Want to see how easy it is to add new infrastructure? Let's add a small EC2 instance!

### Step 8 (Optional): Add an EC2 Instance

Your `main.tf` file already contains commented-out code for an EC2 instance. Here's how to enable it:

**1. Uncomment the EC2 resource:**
```bash
# Edit main.tf to uncomment the EC2 instance resource
nano main.tf

# Find this section near the end and remove the # symbols:
# resource "aws_instance" "example_ec2" {
#   ami           = "ami-0c02fb55956c7d316"
#   instance_type = "t2.micro"
#   
#   tags = {
#     Name        = "Example EC2 Instance"
#     Environment = "Tutorial"
#   }
# }
```

**2. Also uncomment the EC2 outputs in outputs.tf:**
```bash
nano outputs.tf

# Uncomment the EC2 outputs at the end of the file
```

**3. Preview the changes:**
```bash
terraform plan
```
You'll see Terraform wants to add 1 new resource (the EC2 instance).

**4. Apply the changes:**
```bash
terraform apply
```

**5. Check your new instance:**
```bash
# See the new outputs
terraform output

# Check the instance in AWS CLI
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' --output table
```

**What just happened:**
- ✅ You added a new resource to existing infrastructure
- ✅ Terraform only created the new resource (didn't touch existing ones)
- ✅ You now have a running EC2 instance alongside your Lambda and S3

**Note**: In Cloud Guru environments, you cannot create new IAM roles via CLI/Terraform, so this EC2 instance uses default permissions. In a production setup, you'd typically create a custom IAM role for EC2.

## Cleaning Up

When you're done experimenting, clean up to avoid AWS charges:

```bash
terraform destroy
```

Type `yes` when prompted. This will delete:
- Your Lambda function
- Your S3 bucket and all files in it
- CloudWatch log groups
- EC2 instance (if you created it)

**Note**: The IAM role (`TerraformLambdaRole`) will remain since it was created outside of Terraform.

If you used CloudFormation to create the role, you can delete it with:
```bash
aws cloudformation delete-stack --stack-name terraform-lambda-role
```

Or delete it manually in the IAM Console if no longer needed.

## What You've Learned

Congratulations! You've just:

✅ **Written Infrastructure as Code** - You described AWS resources using Terraform
✅ **Created cloud resources** - S3 bucket, Lambda function using existing IAM role
✅ **Deployed serverless code** - Your Python function runs without managing servers
✅ **Integrated AWS services** - Lambda talks to S3 automatically
✅ **Used best practices** - Separate files for different concerns
✅ **Combined manual and automated approaches** - IAM role manually, infrastructure with Terraform
✅ **Extended existing infrastructure** - Added new resources (EC2) to existing setup

## Next Steps

Now that you understand the basics, you can:

1. **Modify the Lambda code** - Change what the function does
2. **Add more AWS resources** - Maybe a database or API Gateway
3. **Learn about Terraform modules** - Reusable components
4. **Set up multiple environments** - Dev, staging, production
5. **Add automated testing** - Test your infrastructure code
6. **Explore the advanced tutorial** - Check out the modular version in the parent directory

## Terraform Concepts You've Used

- **Resources**: The things you want to create (S3 bucket, Lambda function)
- **Providers**: Plugins that know how to talk to cloud services (AWS)
- **Variables**: Customizable settings for your infrastructure
- **Outputs**: Information to display after creation
- **State**: Terraform's memory of what it created (stored in `terraform.tfstate`)

## Helpful Resources

- [Terraform Documentation](https://terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Learn](https://learn.hashicorp.com/terraform)

## Need Help?

If you get stuck:
1. Check the error message carefully - Terraform gives good error descriptions
2. Make sure your AWS credentials are set up correctly
3. Verify your AWS permissions
4. Try `terraform plan` before `terraform apply`
5. Check AWS CloudWatch logs for Lambda function errors

Happy learning! 🚀