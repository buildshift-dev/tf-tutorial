#!/bin/bash

# AWS Credentials Loader for A Cloud Guru Labs
# This script loads AWS credentials from ~/.aws/credentials file and exports them as environment variables
# Use this when you see "invalid security token" errors in A Cloud Guru labs

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

echo "=================================="
echo "AWS Credentials Loader"
echo "for A Cloud Guru Labs"
echo "=================================="

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please run the setup script first:"
    print_error "  ./setup-cloud9.sh"
    exit 1
fi

# Check if credentials file exists
if [ ! -f ~/.aws/credentials ]; then
    print_error "AWS credentials file not found at ~/.aws/credentials"
    print_error "Please make sure your A Cloud Guru lab is running and AWS CLI is configured."
    exit 1
fi

print_status "Loading AWS credentials from ~/.aws/credentials..."

# Extract credentials from AWS config
AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id 2>/dev/null || echo "")
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key 2>/dev/null || echo "")
AWS_SESSION_TOKEN=$(aws configure get aws_session_token 2>/dev/null || echo "")
AWS_REGION=$(aws configure get region 2>/dev/null || echo "us-east-1")

# Check if credentials were found
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    print_error "AWS Access Key ID not found in credentials file"
    print_error "Make sure your A Cloud Guru lab is properly configured"
    exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    print_error "AWS Secret Access Key not found in credentials file"
    exit 1
fi

# Export credentials as environment variables
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="$AWS_REGION"

# Export session token if it exists (required for A Cloud Guru temporary credentials)
if [ -n "$AWS_SESSION_TOKEN" ]; then
    export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
    print_status "Session token found and loaded"
else
    print_warning "No session token found - this may cause authentication issues"
fi

print_success "Credentials loaded successfully!"

# Display environment variables (with partial masking for security)
echo ""
print_status "Environment Variables Set:"
echo -e "  ${BLUE}AWS_ACCESS_KEY_ID${NC}     = ${AWS_ACCESS_KEY_ID:0:10}...${AWS_ACCESS_KEY_ID: -4}"
echo -e "  ${BLUE}AWS_SECRET_ACCESS_KEY${NC} = ${AWS_SECRET_ACCESS_KEY:0:6}...[HIDDEN]"
if [ -n "$AWS_SESSION_TOKEN" ]; then
    echo -e "  ${BLUE}AWS_SESSION_TOKEN${NC}     = ${AWS_SESSION_TOKEN:0:20}...[HIDDEN]"
else
    echo -e "  ${BLUE}AWS_SESSION_TOKEN${NC}     = ${RED}(not set)${NC}"
fi
echo -e "  ${BLUE}AWS_DEFAULT_REGION${NC}    = $AWS_DEFAULT_REGION"

# Test the credentials
print_status "Testing AWS credentials..."

if aws sts get-caller-identity &> /dev/null; then
    print_success "✅ AWS credentials are working!"
    
    # Show account info
    ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null)
    USER_ARN=$(aws sts get-caller-identity --query 'Arn' --output text 2>/dev/null)
    
    echo ""
    print_status "AWS Account ID: $ACCOUNT_ID"
    print_status "User/Role: $USER_ARN"
    
    # Check credential expiration if possible
    if [ -n "$AWS_SESSION_TOKEN" ]; then
        print_warning "⏰ A Cloud Guru credentials expire quickly (1-3 hours)!"
        print_status "💡 If you get 'token expired' errors later, re-run this script"
        print_status "🔄 You may need to refresh your A Cloud Guru lab session"
    fi
    
    echo ""
    print_success "🚀 You can now run Terraform commands!"
    echo ""
    echo "Next steps:"
    echo -e "  ${YELLOW}cd quick-tf-intro/       # For beginners${NC}"
    echo -e "  ${YELLOW}cd sample-tf-project/    # For advanced users${NC}"
    echo ""
    echo "Then run:"
    echo -e "  ${YELLOW}terraform init${NC}"
    echo -e "  ${YELLOW}terraform plan${NC}"
    echo -e "  ${YELLOW}terraform apply${NC}"
    
else
    print_error "❌ AWS credentials test failed!"
    print_error "Common issues:"
    echo "  1. A Cloud Guru lab session has expired - restart your lab"
    echo "  2. Credentials file is outdated - refresh your lab environment"
    echo "  3. Missing session token - check ~/.aws/credentials file"
    echo ""
    print_status "Current credentials file contents:"
    cat ~/.aws/credentials 2>/dev/null || echo "Cannot read credentials file"
    exit 1
fi

echo ""
print_status "💡 Pro tip: Run this script whenever you start a new terminal session"
print_status "    or when you get 'invalid security token' errors"