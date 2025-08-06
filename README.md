# Terraform AWS Lambda + S3 Tutorials

This repository contains **two complete Terraform tutorials** that demonstrate how to create AWS Lambda functions with S3 integration. Both tutorials create the same functionality but use different approaches to teach different aspects of Terraform.

## 🎯 What You'll Build

Both projects create a serverless system where:
- **AWS Lambda Function** runs Python code
- **S3 Bucket** stores files  
- **Lambda creates timestamp files** in S3 each time it executes
- **IAM roles** provide secure permissions

## 📚 Choose Your Learning Path

### 🚀 [quick-tf-intro/](./quick-tf-intro/) - **Start Here if You're New to Terraform**

**Perfect for:** Complete Terraform beginners  
**Time:** 30-45 minutes  
**Structure:** Simple - all files in root directory

```
quick-tf-intro/
├── README.md           # Beginner-friendly tutorial
├── main.tf            # Single file with all resources
├── variables.tf       # Simple customization
├── outputs.tf         # Results display
└── lambda_function.py # Python code with comments
```

**What you'll learn:**
- ✅ What is Infrastructure as Code?
- ✅ Basic Terraform concepts (resources, variables, outputs)
- ✅ How to create AWS resources with Terraform
- ✅ Simple project structure
- ✅ Basic AWS Lambda and S3 integration

**Quick start:**
```bash
cd quick-tf-intro
terraform init
terraform apply
```

---

### ⚡ [sample-tf-project/](./sample-tf-project/) - **Production-Ready Architecture**

**Perfect for:** Those ready for real-world Terraform patterns  
**Time:** 1-2 hours  
**Structure:** Modular - follows industry best practices

```
sample-tf-project/
├── README.md
├── infrastructure/
│   ├── environments/dev/    # Environment isolation
│   └── modules/            # Reusable components
│       ├── lambda/
│       └── s3/
├── src/lambda/             # Application code
├── scripts/                # Automation tools
└── .gitignore
```

**What you'll learn:**
- ✅ Terraform modules and reusability
- ✅ Multi-environment setup (dev/staging/prod)
- ✅ Project organization best practices
- ✅ Automation scripts
- ✅ Advanced security configurations
- ✅ Production-ready patterns

**Quick start:**
```bash
cd sample-tf-project
./scripts/deploy.sh dev apply
./scripts/test-lambda.sh dev
```

## 🛠 Prerequisites

### Required
- **AWS Account** with CLI configured
- **AWS Cloud9** (recommended) or local machine with:
  - Terraform >= 1.0
  - AWS CLI
  - Python 3.11

### AWS Permissions Needed
- S3: Create buckets, put/get objects
- Lambda: Create functions, manage code
- CloudWatch: Create log groups
- IAM: Pass existing roles to services (iam:PassRole)

**Note**: You'll create the Lambda execution role manually in the AWS Console (covered in tutorials)

## ⚡ Quick Setup for Cloud9

If you're using **AWS Cloud9** with Amazon Linux 2023, run our setup script to install everything automatically:

```bash
# Clone the repository
git clone <this-repo-url>
cd tf-tutorial

# Run the setup script (installs Python 3.11, Terraform, Git, and more)
chmod +x setup-cloud9.sh
./setup-cloud9.sh

# Reload your shell to use new aliases
source ~/.bashrc

# Verify installations
python --version    # Should show Python 3.11.x
terraform --version # Should show Terraform v1.7.0
```

The setup script will:
- ✅ Install Python 3.11 and pip
- ✅ Create `python` and `pip` aliases
- ✅ Install Terraform 1.7.0
- ✅ Verify Git installation
- ✅ Install useful tools (jq, zip/unzip)
- ✅ Check AWS CLI configuration
- ✅ Set up AWS CLI and Terraform tab completion
- ✅ Add common shell aliases (ll, la, cls, etc.)

### 🚀 Enhanced Setup for Advanced Development

For additional development tools (Docker, .NET, AWS SAM CLI, AWS CDK, Spark), use the enhanced setup script:

```bash
# Run the enhanced setup script (interactive - asks yes/no for each tool)
chmod +x setup-cloud9-plus.sh
./setup-cloud9-plus.sh

# Reload your shell
source ~/.bashrc
```

The enhanced setup script includes:
- ✅ **Docker** - Container development and deployment
- ✅ **.NET 8 SDK** - For .NET applications and AWS Lambda functions
- ✅ **AWS SAM CLI** - Serverless Application Model for local testing
- ✅ **AWS CDK** - Infrastructure as Code using programming languages
- ✅ **Java 17** - Required for Spark and modern Java development
- ✅ **Apache Spark 3.5.4** - Compatible with AWS Glue 5.0 for big data processing

**Interactive Experience**: The script asks for confirmation before installing each tool, so you can choose only what you need.

## 🔑 AWS Credentials Setup

If you get **"invalid security token"** errors:

```bash
# Use the credentials loader script if needed
./load-aws-creds.sh

# Or configure manually:
aws configure
```

This loads credentials from your AWS configuration and tests them.

## 🏁 Getting Started

### Option 1: Start with Basics (Recommended for Beginners)
```bash
git clone <this-repo>
cd tf-tutorial/quick-tf-intro
# Follow the README.md in that folder
```

### Option 2: Jump to Advanced Patterns  
```bash
git clone <this-repo>
cd tf-tutorial/sample-tf-project  
# Follow the README.md in that folder
```

### Option 3: Do Both (Full Learning Experience)
1. Complete `quick-tf-intro` first to learn fundamentals
2. Then explore `sample-tf-project` to see production patterns
3. Compare the approaches to understand when to use each

## 📋 Repository Structure

```
tf-tutorial/
├── README.md                    # This file - start here
├── setup-cloud9.sh             # Basic setup script for Cloud9 environment
├── setup-cloud9-plus.sh        # Enhanced setup with Docker, .NET, SAM CLI, CDK, Spark
├── load-aws-creds.sh           # Load AWS credentials from file
│
├── quick-tf-intro/             # 🚀 Beginner Tutorial
│   ├── README.md               # Complete beginner guide
│   ├── main.tf                 # All resources in one file
│   ├── variables.tf            # Simple settings
│   ├── outputs.tf              # Basic outputs
│   ├── lambda_function.py      # Python function with comments
│   └── .gitignore              # Git ignore rules
│
└── sample-tf-project/          # ⚡ Advanced Tutorial  
    ├── README.md               # Production patterns guide
    ├── infrastructure/
    │   ├── environments/dev/    # Environment-specific config
    │   └── modules/             # Reusable Terraform modules
    │       ├── lambda/          # Lambda module
    │       └── s3/              # S3 module
    ├── src/lambda/              # Application source code
    ├── scripts/                 # Deployment automation
    └── .gitignore
```

## 🎓 Learning Progression

### Phase 1: Fundamentals
👉 **Start with `quick-tf-intro/`**
- Understand what Terraform does
- Learn basic syntax and concepts
- Get comfortable with terraform commands
- See immediate results

### Phase 2: Best Practices  
👉 **Move to `sample-tf-project/`**
- Learn modular architecture
- Understand environment separation  
- Practice automation scripts
- See production-ready patterns

### Phase 3: Compare & Contrast
- Compare the two approaches
- Understand when to use simple vs modular structures
- Learn refactoring from simple to complex

## 💡 Key Differences

| Aspect | quick-tf-intro | sample-tf-project |
|--------|----------------|-------------------|
| **Complexity** | Simple | Advanced |
| **File Structure** | Flat (root level) | Modular (nested) |
| **Best for** | Learning basics | Production use |
| **Time Investment** | 30-45 minutes | 1-2 hours |
| **Reusability** | Limited | High |
| **Environments** | Single | Multi (dev/staging/prod) |
| **Automation** | Manual commands | Scripts provided |

## 🔧 What Gets Created

Both tutorials create these AWS resources:
- **S3 Bucket** with security settings (versioning, encryption, lifecycle)
- **Lambda Function** (Python 3.11 runtime) 
- **CloudWatch Log Group** for monitoring

**Prerequisites**: You'll manually create an IAM role for Lambda execution (instructions included)

## 🧪 Testing Your Deployment

Both projects include testing instructions:
- AWS CLI commands to invoke Lambda
- Methods to verify S3 file creation
- Console-based testing options
- Multiple invocation examples

## 🚮 Cleanup

Each project includes cleanup instructions:
```bash
# From either project directory:
terraform destroy
```

## 🤝 Contributing

Found an issue or want to improve the tutorials?
- Open an issue for bugs or questions
- Submit a PR for improvements
- Suggest additional scenarios or examples

## 📖 Additional Resources

- [Terraform Documentation](https://terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)  
- [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/)
- [Terraform Learn](https://learn.hashicorp.com/terraform)

## ❓ Getting Help

**For Terraform basics:** Start with `quick-tf-intro/README.md`  
**For advanced patterns:** Check `sample-tf-project/README.md`  
**For AWS-specific issues:** Review AWS CloudWatch logs  
**For general questions:** Each project's README has troubleshooting sections

---

**Happy Learning!** 🚀 Choose your path and start building with Infrastructure as Code!