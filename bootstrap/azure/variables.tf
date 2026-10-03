variable "subscription_id" {
  description = "Subscription ID."
  type        = string
}

variable "location" {
  description = "Backend storage region."
  type        = string
}

variable "resource_group_name" {
  description = "Dedicated backend resource group name."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique 3-24 lowercase letters/numbers."
  type        = string
}

variable "container_name" {
  description = "Private state container name."
  type        = string
}
