output "resource_group_name" {
  description = "New lab resource group."
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "VNet ID."
  value       = azurerm_virtual_network.this.id
}

output "subnet_id" {
  description = "Subnet ID."
  value       = azurerm_subnet.this.id
}

output "vm_id" {
  description = "VM ID."
  value       = azurerm_linux_virtual_machine.this.id
}

output "public_ip" {
  description = "Static public IPv4."
  value       = azurerm_public_ip.this.ip_address
}

output "private_ip" {
  description = "Private IPv4."
  value       = azurerm_network_interface.this.private_ip_address
}
