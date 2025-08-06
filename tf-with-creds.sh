#!/bin/bash

# Terraform wrapper that automatically checks/loads AWS credentials
# Usage: ./tf-with-creds.sh [terraform-command]
# Examples: 
#   ./tf-with-creds.sh init
#   ./tf-with-creds.sh plan
#   ./tf-with-creds.sh apply

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if terraform command provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 [terraform-command]"
    echo ""
    echo "Examples:"
    echo "  $0 init     # terraform init with credential check"
    echo "  $0 plan     # terraform plan with credential check"  
    echo "  $0 apply    # terraform apply with credential check"
    echo "  $0 destroy  # terraform destroy with credential check"
    exit 1
fi

print_status "🔍 Checking AWS credentials before running Terraform..."

# Function to load credentials
load_credentials() {
    if [ -f "./load-aws-creds.sh" ]; then
        print_status "Loading credentials..."
        source ./load-aws-creds.sh > /dev/null 2>&1 || {
            print_error "Failed to load credentials"
            exit 1
        }
    else
        print_error "load-aws-creds.sh not found. Make sure you're in the tf-tutorial directory."
        exit 1
    fi
}

# Check if credentials are already loaded and valid
if [ -n "$AWS_ACCESS_KEY_ID" ] && aws sts get-caller-identity &> /dev/null; then
    print_success "✅ AWS credentials are valid"
else
    print_status "⚠️  Need to load/refresh credentials..."
    load_credentials
fi

# Check if we're in a terraform directory
if [ ! -f "main.tf" ] && [ ! -f "infrastructure/environments/dev/main.tf" ]; then
    print_error "No Terraform configuration found!"
    print_error "Make sure you're in quick-tf-intro/ or sample-tf-project/ directory"
    exit 1
fi

# Run terraform command
print_status "🚀 Running: terraform $*"
echo ""

terraform "$@"

# Check if command failed due to credential issues
if [ $? -ne 0 ]; then
    echo ""
    print_error "Terraform command failed!"
    print_status "If you got credential errors, try:"
    print_status "  1. Refresh your A Cloud Guru lab"
    print_status "  2. Re-run: ./load-aws-creds.sh"
    print_status "  3. Then retry your terraform command"
fi