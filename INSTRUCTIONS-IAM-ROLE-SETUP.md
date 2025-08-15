# IAM Role Setup for Terraform Lambda Tutorials

All Terraform tutorials in this repository require a Lambda execution role. This guide shows you how to create it using CloudFormation.

## Why CloudFormation Instead of Manual Creation?

**Cloud Guru Policy Limitations**: In A Cloud Guru sandbox environments, IAM policies often prevent direct IAM role creation through the console or individual AWS CLI commands. However, CloudFormation stacks typically have the necessary permissions to create IAM resources as part of infrastructure templates.

**Benefits in Cloud Guru**:
- ✅ **Bypasses console restrictions**: Works when manual IAM console access is limited
- ✅ **Consistent deployment**: Same command works across different Cloud Guru labs
- ✅ **Automated cleanup**: Easy to remove when lab session ends
- ✅ **Version controlled**: Template can be tracked and modified as needed

## Quick Setup

### One Command Deploy:
```bash
# Deploy IAM role for Lambda (required for all tutorials)
aws cloudformation create-stack \
  --stack-name terraform-lambda-role \
  --template-body file://iam-role-cloudformation.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-east-1
```

### Wait for Completion:
```bash
# Wait for the stack to complete
aws cloudformation wait stack-create-complete --stack-name terraform-lambda-role

# Verify the role was created
aws cloudformation describe-stacks \
  --stack-name terraform-lambda-role \
  --query 'Stacks[0].Outputs[?OutputKey==`RoleName`].OutputValue' \
  --output text
```

## What Gets Created

The CloudFormation template creates:
- ✅ **IAM Role**: `TerraformLambdaRole` (or custom name)
- ✅ **Lambda Basic Execution Policy**: For CloudWatch logging
- ✅ **S3 Full Access Policy**: For S3 operations
- ✅ **Proper Trust Policy**: Allows Lambda service to assume the role

## Verify Success

You should see output like:
```
TerraformLambdaRole
```

You can also check in the AWS Console:
1. Go to **IAM > Roles**
2. Find **TerraformLambdaRole**
3. Verify it has the attached policies

## Custom Role Name (Optional)

To use a different role name:
```bash
aws cloudformation create-stack \
  --stack-name terraform-lambda-role \
  --template-body file://iam-role-cloudformation.yaml \
  --parameters ParameterKey=RoleName,ParameterValue=MyCustomRoleName \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-east-1
```

**Important**: If you use a custom name, update the `lambda_role_name` variable in your Terraform configuration.

## Use with Tutorials

After creating the role, you can proceed with any tutorial:

- **quick-tf-intro/**: References `TerraformLambdaRole` by default
- **sample-tf-project/**: Uses `lambda_role_name` variable (default: `TerraformLambdaRole`)
- **sample-tf-state-lock/**: Uses `lambda_role_name` variable (default: `TerraformLambdaRole`)

## Troubleshooting

### Role Already Exists Error
```
Role with name TerraformLambdaRole already exists
```
**Solution**: The role is already created, you can proceed with the tutorials.

### Insufficient Permissions Error
```
User is not authorized to perform: iam:CreateRole
```
**Solutions**:
1. **In Cloud Guru**: Try the CloudFormation approach anyway - it often works even when direct IAM access is blocked
2. **In regular AWS**: Ensure your AWS credentials have IAM permissions to create roles and attach policies
3. **Alternative**: Contact your Cloud Guru lab administrator if CloudFormation also fails

### Check Existing Role
```bash
# Check if role exists
aws iam get-role --role-name TerraformLambdaRole

# List attached policies
aws iam list-attached-role-policies --role-name TerraformLambdaRole
```

## Cleanup When Done

After completing all tutorials, remove the IAM role:
```bash
# Delete the CloudFormation stack
aws cloudformation delete-stack --stack-name terraform-lambda-role

# Wait for deletion
aws cloudformation wait stack-delete-complete --stack-name terraform-lambda-role
```

Or delete manually in AWS Console:
1. Go to **IAM > Roles**
2. Select **TerraformLambdaRole**
3. Click **Delete**

## Multiple Projects

You can reuse the same IAM role for multiple projects by:
1. Using the same role name across projects
2. Or creating project-specific roles with different stack names:

```bash
# Project 1
aws cloudformation create-stack \
  --stack-name project1-lambda-role \
  --template-body file://iam-role-cloudformation.yaml \
  --parameters ParameterKey=RoleName,ParameterValue=Project1LambdaRole \
  --capabilities CAPABILITY_NAMED_IAM

# Project 2
aws cloudformation create-stack \
  --stack-name project2-lambda-role \
  --template-body file://iam-role-cloudformation.yaml \
  --parameters ParameterKey=RoleName,ParameterValue=Project2LambdaRole \
  --capabilities CAPABILITY_NAMED_IAM
```

---

**Next Steps**: Choose your tutorial and follow its README.md for deployment instructions!