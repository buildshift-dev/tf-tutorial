variable "bucket_name" {
  description = "Base name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "file_retention_days" {
  description = "Number of days to retain files in S3"
  type        = number
  default     = 30
}