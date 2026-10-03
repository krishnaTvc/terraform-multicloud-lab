variable "name" {
  description = "Resource name prefix."
  type        = string
}

variable "project_id" {
  description = "Existing billing-enabled GCP project ID."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
}

variable "zone" {
  description = "Zone in the selected region."
  type        = string
}

variable "subnet_cidr" {
  description = "Regional subnet CIDR."
  type        = string
}

variable "machine_type" {
  description = "GCE machine type."
  type        = string
}

variable "admin_username" {
  description = "Linux SSH user."
  type        = string
}

variable "ssh_cidr" {
  description = "Your public IPv4 address with /32."
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to an existing public SSH key."
  type        = string
}
