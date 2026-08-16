output "bucket_id" {
  value = var.enable_s3 ? aws_s3_bucket.bucket[0].id : null
}

output "bucket_arn" {
  value = var.enable_s3 ? aws_s3_bucket.bucket[0].arn : null
}

output "bucket_region" {
  value = var.enable_s3 ? aws_s3_bucket.bucket[0].region : null
}