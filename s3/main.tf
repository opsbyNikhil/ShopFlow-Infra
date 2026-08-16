resource "aws_s3_bucket" "bucket" {
  count = var.enable_s3 ? 1 : 0

  bucket        = var.bucket_info.bucket_name
  force_destroy = var.bucket_info.force_destroy

  tags = {
    Name = var.bucket_info.bucket_name
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.bucket[0].id

  versioning_configuration {
    status = var.bucket_info.versioning_enabled ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  count = var.enable_s3 ? 1 : 0

  bucket = aws_s3_bucket.bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}