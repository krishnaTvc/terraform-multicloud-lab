output "bucket_name" {
  description = "Copy to gcp/backend.hcl."
  value       = google_storage_bucket.state.name
}
