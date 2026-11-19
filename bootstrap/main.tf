terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws       = { source = "hashicorp/aws", version = "~> 5.0" }
    random    = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

provider "aws" {
  region = "ap-south-1"
}

variable "state_bucket_prefix" {
  description = "Prefix for the Terraform state S3 bucket"
  type        = string
  default     = "capstone-tf-state"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "tf_state" {
  bucket        = "${var.state_bucket_prefix}-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tf_state" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "${var.state_bucket_prefix}-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "state_bucket" {
  value = aws_s3_bucket.tf_state.bucket
}

output "lock_table" {
  value = aws_dynamodb_table.tf_lock.name
}

