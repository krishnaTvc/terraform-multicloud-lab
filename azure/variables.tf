variable "name" {
  description = "Resource name prefix; use a new name for this fresh lab."
  type        = string
}

variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "vnet_cidr" {
  description = "VNet IPv4 CIDR."
  type        = string
}

variable "subnet_cidr" {
  description = "Subnet CIDR inside VNet."
  type        = string
}

variable "vm_size" {
  description = "Azure VM size available in your region."
  type        = string
}

variable "admin_username" {
  description = "Linux administrator username."
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
