variable "project_id" {
  description = "Existing billing-enabled project ID."
  type        = string
}

variable "bucket_name" {
  description = "Globally unique GCS bucket name."
  type        = string
}

variable "location" {
  description = "GCS bucket location."
  type        = string
}
