#!/bin/bash

# Setup script for Cloud9 AWS Linux 2023 instances - Enhanced Edition
# This script installs Docker, .NET 8, AWS SAM CLI, AWS CDK, Java 17, and Spark 3.5.4
# Compatible with AWS Glue 5.0

set -e

echo "=================================="
echo "Cloud9 AWS Linux 2023 Setup Script"
echo "Enhanced Edition - Interactive"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_question() {
    echo -e "${CYAN}[QUESTION]${NC} $1"
}

# Function to ask yes/no questions
ask_yes_no() {
    local question="$1"
    local response
    
    while true; do
        print_question "$question (y/n): "
        read -r response
        case $response in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

# Check if running on Amazon Linux
check_os() {
    if [[ ! -f /etc/os-release ]] || ! grep -q "Amazon Linux" /etc/os-release; then
        print_warning "This script is designed for Amazon Linux 2023. Proceeding anyway..."
    else
        print_status "Amazon Linux detected. Proceeding with setup..."
    fi
}

# Update system packages
update_system() {
    if ask_yes_no "Update system packages?"; then
        print_status "Updating system packages..."
        sudo yum update -y
        print_success "System packages updated"
    else
        print_status "Skipping system package update"
    fi
}

# Install Docker
install_docker() {
    if ask_yes_no "Install Docker?"; then
        print_status "Checking for Docker..."
        
        if command -v docker &> /dev/null; then
            print_success "Docker is already installed: $(docker --version)"
            return
        fi
        
        print_status "Installing Docker..."
        sudo yum install -y docker
        
        # Start and enable Docker service
        sudo systemctl start docker
        sudo systemctl enable docker
        
        # Add current user to docker group
        sudo usermod -a -G docker $USER
        
        print_success "Docker installed successfully"
        print_warning "You may need to log out and back in for Docker group permissions to take effect"
        print_status "Docker version: $(docker --version)"
    else
        print_status "Skipping Docker installation"
    fi
}

# Install .NET 8
install_dotnet8() {
    if ask_yes_no "Install .NET 8 SDK?"; then
        print_status "Checking for .NET 8..."
        
        if command -v dotnet &> /dev/null && dotnet --version | grep -q "^8\."; then
            print_success ".NET 8 is already installed: $(dotnet --version)"
            return
        fi
        
        print_status "Installing .NET 8 SDK..."
        
        # Add Microsoft package repository
        sudo rpm -Uvh https://packages.microsoft.com/config/centos/8/packages-microsoft-prod.rpm
        
        # Install .NET 8 SDK
        sudo yum install -y dotnet-sdk-8.0
        
        # Verify installation
        if command -v dotnet &> /dev/null; then
            print_success ".NET 8 SDK installed: $(dotnet --version)"
        else
            print_error ".NET 8 SDK installation failed"
            exit 1
        fi
    else
        print_status "Skipping .NET 8 installation"
    fi
}

# Install AWS SAM CLI
install_sam_cli() {
    if ask_yes_no "Install AWS SAM CLI?"; then
        print_status "Checking for AWS SAM CLI..."
        
        if command -v sam &> /dev/null; then
            print_success "AWS SAM CLI is already installed: $(sam --version)"
            return
        fi
        
        print_status "Installing AWS SAM CLI..."
        
        # Create temporary directory
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        # Download and install SAM CLI
        wget -q https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
        unzip -q aws-sam-cli-linux-x86_64.zip -d sam-installation
        sudo ./sam-installation/install
        
        # Clean up
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        
        # Verify installation
        if command -v sam &> /dev/null; then
            print_success "AWS SAM CLI installed: $(sam --version)"
        else
            print_error "AWS SAM CLI installation failed"
            exit 1
        fi
    else
        print_status "Skipping AWS SAM CLI installation"
    fi
}

# Install AWS CDK
install_aws_cdk() {
    if ask_yes_no "Install AWS CDK?"; then
        print_status "Checking for AWS CDK..."
        
        if command -v cdk &> /dev/null; then
            print_success "AWS CDK is already installed: $(cdk --version)"
            return
        fi
        
        print_status "Installing Node.js (required for AWS CDK)..."
        
        # Install Node.js if not present
        if ! command -v node &> /dev/null; then
            # Install Node.js via NodeSource repository
            curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
            sudo yum install -y nodejs
            print_success "Node.js installed: $(node --version)"
        else
            print_success "Node.js already installed: $(node --version)"
        fi
        
        print_status "Installing AWS CDK..."
        sudo npm install -g aws-cdk
        
        # Verify installation
        if command -v cdk &> /dev/null; then
            print_success "AWS CDK installed: $(cdk --version)"
        else
            print_error "AWS CDK installation failed"
            exit 1
        fi
    else
        print_status "Skipping AWS CDK installation"
    fi
}

# Install Spark 3.5.4 (compatible with AWS Glue 5.0)
install_spark() {
    if ask_yes_no "Install Apache Spark 3.5.4 (AWS Glue 5.0 compatible)?"; then
        print_status "Checking for Spark installation..."
        
        SPARK_HOME="/opt/spark"
        
        if [[ -d "$SPARK_HOME" ]] && [[ -f "$SPARK_HOME/bin/spark-submit" ]]; then
            print_success "Spark is already installed at $SPARK_HOME"
            return
        fi
        
        print_status "Installing Java 17 (required for Spark)..."
        
        # Install Java 17 if not present
        if ! java -version 2>&1 | grep -q "17\."; then
            sudo yum install -y java-17-amazon-corretto-headless
            print_success "Java 17 installed"
        else
            print_success "Java 17 already installed"
        fi
        
        print_status "Installing Apache Spark 3.5.4..."
        
        # Create temporary directory
        TEMP_DIR=$(mktemp -d)
        cd "$TEMP_DIR"
        
        # Download Spark 3.5.4 pre-built for Hadoop 3.3
        SPARK_VERSION="3.5.4"
        HADOOP_VERSION="3"
        SPARK_PACKAGE="spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}"
        
        print_status "Downloading Spark ${SPARK_VERSION}..."
        # e.g., https://archive.apache.org/dist/spark/spark-3.5.4/spark-3.5.4-bin-hadoop3.tgz
        wget "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz"
        
        if [[ $? -ne 0 ]]; then
            print_error "Failed to download Spark"
            exit 1
        fi
        
        # Extract and install
        tar -xzf "${SPARK_PACKAGE}.tgz"
        sudo mv "${SPARK_PACKAGE}" "$SPARK_HOME"
        sudo chown -R $USER:$USER "$SPARK_HOME"
        
        # Clean up
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        
        # Add Spark to PATH and set environment variables
        if ! grep -q "SPARK_HOME" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# Spark 3.5.4 environment variables" >> ~/.bashrc
            echo "export SPARK_HOME=$SPARK_HOME" >> ~/.bashrc
            echo "export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin" >> ~/.bashrc
            echo "export PYSPARK_PYTHON=python3" >> ~/.bashrc
            print_success "Spark environment variables added to ~/.bashrc"
        fi
        
        # Set for current session
        export SPARK_HOME="$SPARK_HOME"
        export PATH="$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin"
        export PYSPARK_PYTHON=python3
        
        print_success "Apache Spark 3.5.4 installed at $SPARK_HOME"
        print_status "Spark version: $($SPARK_HOME/bin/spark-submit --version 2>&1 | grep version | head -1)"
    else
        print_status "Skipping Apache Spark installation"
    fi
}



# Setup shell completions
setup_completions() {
    if ask_yes_no "Setup shell completions for installed tools?"; then
        print_status "Setting up command completions..."
        
        # SAM CLI completion
        if command -v sam &> /dev/null && ! grep -q "sam.*complete" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# SAM CLI completion" >> ~/.bashrc
            echo "complete -C sam sam" >> ~/.bashrc
            print_success "SAM CLI completion added"
        fi
        
        # Docker completion (basic)
        if command -v docker &> /dev/null && ! grep -q "docker.*complete" ~/.bashrc; then
            echo "" >> ~/.bashrc
            echo "# Docker completion (basic)" >> ~/.bashrc
            echo "complete -W 'build run ps images pull push stop rm rmi' docker" >> ~/.bashrc
            print_success "Docker completion added"
        fi
        
        print_success "Shell completions configured"
    else
        print_status "Skipping shell completions setup"
    fi
}


# Display summary and next steps
show_summary() {
    echo ""
    echo "=================================="
    print_success "Setup completed!"
    echo "=================================="
    echo ""
    
    echo -e "${BLUE}Installed Tools Summary:${NC}"
    echo ""
    
    # Check and display what was installed
    if command -v docker &> /dev/null; then
        echo -e "✅ Docker: $(docker --version)"
    fi
    
    if command -v dotnet &> /dev/null; then
        echo -e "✅ .NET: $(dotnet --version)"
    fi
    
    if command -v sam &> /dev/null; then
        echo -e "✅ AWS SAM CLI: $(sam --version | head -1)"
    fi
    
    if command -v cdk &> /dev/null; then
        echo -e "✅ AWS CDK: $(cdk --version)"
    fi
    
    if [[ -d "/opt/spark" ]]; then
        echo -e "✅ Apache Spark: 3.5.4 (AWS Glue 5.0 compatible)"
    fi
    
    
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo ""
    echo "1. Reload your shell to apply all changes:"
    echo -e "   ${YELLOW}source ~/.bashrc${NC}"
    echo ""
    echo "2. For Docker: Log out and back in for group permissions"
    echo ""
    echo "3. Test your installations:"
    echo -e "   ${YELLOW}docker --version${NC}"
    echo -e "   ${YELLOW}dotnet --version${NC}"
    echo -e "   ${YELLOW}sam --version${NC}"
    echo -e "   ${YELLOW}cdk --version${NC}"
    echo -e "   ${YELLOW}\$SPARK_HOME/bin/spark-submit --version${NC}"
    echo ""
    echo "4. For Spark development:"
    echo -e "   ${YELLOW}pyspark  # Start PySpark shell${NC}"
    echo -e "   ${YELLOW}spark-shell  # Start Scala Spark shell${NC}"
    echo ""
    echo "5. For AWS Glue development:"
    echo "   - Use Spark 3.5.4 APIs (compatible with Glue 5.0)"
    echo "   - Test your Glue jobs locally before deployment"
    echo ""
    print_success "Happy coding with your enhanced Cloud9 environment!"
}

# Main execution
main() {
    print_status "Starting Cloud9 Plus interactive setup..."
    echo ""
    
    check_os
    update_system
    install_docker
    install_dotnet8
    install_sam_cli
    install_aws_cdk
    install_spark
    setup_completions
    show_summary
}

# Run main function
main "$@"