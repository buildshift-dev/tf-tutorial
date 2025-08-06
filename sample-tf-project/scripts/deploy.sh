#!/bin/bash

# Terraform deployment script
# Usage: ./scripts/deploy.sh [environment] [action]
# Example: ./scripts/deploy.sh dev plan

set -e

ENVIRONMENT=${1:-dev}
ACTION=${2:-plan}
TERRAFORM_DIR="infrastructure/environments/${ENVIRONMENT}"

echo "=== Terraform ${ACTION} for ${ENVIRONMENT} environment ==="

# Check if Terraform directory exists
if [ ! -d "$TERRAFORM_DIR" ]; then
    echo "Error: Environment directory $TERRAFORM_DIR does not exist"
    exit 1
fi

# Change to Terraform directory
cd "$TERRAFORM_DIR"

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
fi

# Execute the requested action
case $ACTION in
    "init")
        terraform init
        ;;
    "plan")
        terraform plan
        ;;
    "apply")
        terraform apply
        ;;
    "destroy")
        echo "WARNING: This will destroy all resources in the $ENVIRONMENT environment!"
        read -p "Are you sure you want to continue? (yes/no): " confirm
        if [ "$confirm" = "yes" ]; then
            terraform destroy
        else
            echo "Destroy cancelled."
            exit 0
        fi
        ;;
    "output")
        terraform output
        ;;
    "validate")
        terraform validate
        ;;
    "fmt")
        terraform fmt -recursive
        ;;
    *)
        echo "Usage: $0 [environment] [init|plan|apply|destroy|output|validate|fmt]"
        exit 1
        ;;
esac

echo "=== Terraform ${ACTION} completed ==="