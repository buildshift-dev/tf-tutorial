#!/bin/bash

# Terraform Fresh Credentials Wrapper for A Cloud Guru
# This script always loads fresh credentials before running Terraform commands
# Usage: ./tf-fresh.sh [terraform-command] [arguments...]
# Examples:
#   ./tf-fresh.sh init
#   ./tf-fresh.sh plan
#   ./tf-fresh.sh apply
#   ./tf-fresh.sh destroy

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show usage if no arguments
if [ $# -eq 0 ]; then
    echo "Terraform Fresh Credentials Wrapper"
    echo "Usage: $0 [terraform-command] [arguments...]"
    echo ""
    echo "Examples:"
    echo "  $0 init           # terraform init with fresh creds"
    echo "  $0 plan           # terraform plan with fresh creds"
    echo "  $0 apply          # terraform apply with fresh creds"
    echo "  $0 apply -auto-approve"
    echo "  $0 destroy        # terraform destroy with fresh creds"
    echo "  $0 output         # terraform output with fresh creds"
    echo "  $0 validate       # terraform validate with fresh creds"
    echo ""
    echo "This script automatically loads fresh credentials from ~/.aws/credentials"
    echo "before each Terraform command (perfect for A Cloud Guru labs)."
    exit 1
fi

print_status "🔄 Loading fresh AWS credentials from ~/.aws/credentials..."

# Check if credentials file exists
if [ ! -f ~/.aws/credentials ]; then
    print_error "AWS credentials file not found at ~/.aws/credentials"
    print_error "Make sure your A Cloud Guru lab is running and configured."
    exit 1
fi

# Always get fresh credentials from file
AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id 2>/dev/null || echo "")
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key 2>/dev/null || echo "")
AWS_SESSION_TOKEN=$(aws configure get aws_session_token 2>/dev/null || echo "")
AWS_REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")

# Validate credentials were found
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    print_error "AWS Access Key ID not found in credentials file"
    print_error "Check your A Cloud Guru lab configuration"
    exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    print_error "AWS Secret Access Key not found in credentials file"
    exit 1
fi

# Export fresh credentials
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="$AWS_REGION"

# Export session token if available
if [ -n "$AWS_SESSION_TOKEN" ]; then
    export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
    print_success "✅ Fresh credentials loaded (with session token: ${#AWS_SESSION_TOKEN} chars)"
else
    print_warning "⚠️  No session token found (this might cause issues with A Cloud Guru)"
fi

# Show credential info (masked for security)
print_status "Using credentials:"
echo -e "  Access Key: ${BLUE}${AWS_ACCESS_KEY_ID:0:10}...${AWS_ACCESS_KEY_ID: -4}${NC}"
echo -e "  Region: ${BLUE}$AWS_DEFAULT_REGION${NC}"

# Quick test of credentials
print_status "🧪 Testing AWS credentials..."
if aws sts get-caller-identity &> /dev/null; then
    ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null)
    print_success "✅ Credentials working! Account: $ACCOUNT_ID"
else
    print_error "❌ Credential test failed!"
    print_error "Try refreshing your A Cloud Guru lab session"
    exit 1
fi

# Check if we're in a Terraform directory
if [ ! -f "main.tf" ] && [ ! -f "terraform.tf" ] && [ ! -d ".terraform" ]; then
    print_warning "⚠️  No Terraform configuration detected in current directory"
    print_status "Make sure you're in quick-tf-intro/ or sample-tf-project/environments/dev/"
fi

# Run terraform command with fresh credentials
echo ""
print_status "🚀 Running: terraform $*"
print_status "📁 Working directory: $(pwd)"
echo ""

# Execute terraform command
terraform "$@"

# Capture exit code
TERRAFORM_EXIT_CODE=$?

echo ""
if [ $TERRAFORM_EXIT_CODE -eq 0 ]; then
    print_success "✅ Terraform command completed successfully!"
else
    print_error "❌ Terraform command failed (exit code: $TERRAFORM_EXIT_CODE)"
    echo ""
    print_warning "Common A Cloud Guru issues:"
    echo "  1. 🔄 Lab session expired - refresh your A Cloud Guru lab"
    echo "  2. 🕐 Credentials rotated during execution - re-run this script"
    echo "  3. 🌍 Wrong region - check if your lab uses a different region"
    echo "  4. 📁 Wrong directory - make sure you're in the Terraform project folder"
    echo ""
    print_status "💡 Try running the command again: $0 $*"
fi

exit $TERRAFORM_EXIT_CODE