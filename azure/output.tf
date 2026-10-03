output "resource_group_name" {
  description = "New lab resource group."
  value       = module.lab.resource_group_name
}

output "vnet_id" {
  description = "VNet ID."
  value       = module.lab.vnet_id
}

output "subnet_id" {
  description = "Subnet ID."
  value       = module.lab.subnet_id
}

output "vm_id" {
  description = "VM ID."
  value       = module.lab.vm_id
}

output "public_ip" {
  description = "Static public IPv4."
  value       = module.lab.public_ip
}

output "private_ip" {
  description = "Private IPv4."
  value       = module.lab.private_ip
}
