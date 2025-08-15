# Create S3 bucket for storing timestamp files
resource "aws_s3_bucket" "timestamp_bucket" {
  bucket = "${var.bucket_name}-${var.environment}"
}

# Configure S3 bucket versioning
resource "aws_s3_bucket_versioning" "timestamp_bucket_versioning" {
  bucket = aws_s3_bucket.timestamp_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "timestamp_bucket_pab" {
  bucket = aws_s3_bucket.timestamp_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Add server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "timestamp_bucket_encryption" {
  bucket = aws_s3_bucket.timestamp_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Add lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "timestamp_bucket_lifecycle" {
  bucket = aws_s3_bucket.timestamp_bucket.id

  rule {
    id     = "timestamp_files_lifecycle"
    status = "Enabled"

    filter {
      prefix = ""  # Apply to all objects in the bucket
    }

    expiration {
      days = var.file_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}