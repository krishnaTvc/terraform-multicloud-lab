output "bucket_name" {
  description = "Copy to aws/backend.hcl."
  value       = aws_s3_bucket.state.id
}

output "region" {
  description = "Copy to aws/backend.hcl."
  value       = var.region
}
