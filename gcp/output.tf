output "network_id" {
  description = "VPC network ID."
  value       = module.lab.network_id
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
  description = "Ephemeral public IPv4."
  value       = module.lab.public_ip
}

output "private_ip" {
  description = "Private IPv4."
  value       = module.lab.private_ip
}
