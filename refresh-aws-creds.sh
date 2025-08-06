#!/bin/bash

# AWS Credentials Refresh Helper for A Cloud Guru Labs
# Quick script to check if credentials are still valid and refresh if needed

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
echo "AWS Credentials Status Checker"
echo "=================================="

# Check if credentials are currently set
if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    print_warning "No AWS credentials loaded in environment"
    print_status "Run: ./load-aws-creds.sh"
    exit 1
fi

# Test current credentials
print_status "Testing current AWS credentials..."

if aws sts get-caller-identity &> /dev/null; then
    print_success "✅ Current credentials are still valid!"
    
    # Show current info
    ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null)
    echo -e "  Account: ${GREEN}$ACCOUNT_ID${NC}"
    echo -e "  Access Key: ${BLUE}${AWS_ACCESS_KEY_ID:0:10}...${AWS_ACCESS_KEY_ID: -4}${NC}"
    echo -e "  Region: ${BLUE}$AWS_DEFAULT_REGION${NC}"
    
    if [ -n "$AWS_SESSION_TOKEN" ]; then
        print_status "Session token is present (temporary credentials)"
    fi
    
    echo ""
    print_success "🚀 Ready for Terraform commands!"
    
else
    print_error "❌ Current credentials have expired or are invalid"
    echo ""
    print_warning "Common solutions:"
    echo "  1. 🔄 Refresh your A Cloud Guru lab session"
    echo "  2. 📁 Check if ~/.aws/credentials has been updated"  
    echo "  3. 🔧 Re-run: ./load-aws-creds.sh"
    echo ""
    
    # Offer to reload automatically
    echo -n "Would you like to reload credentials now? (y/n): "
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_status "Reloading credentials..."
        ./load-aws-creds.sh
    else
        print_status "Manual reload: ./load-aws-creds.sh"
    fi
fi