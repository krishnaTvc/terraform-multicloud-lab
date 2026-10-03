output "network_id" {
  description = "VPC network ID."
  value       = google_compute_network.this.id
}

output "subnet_id" {
  description = "Subnet ID."
  value       = google_compute_subnetwork.this.id
}

output "vm_id" {
  description = "VM ID."
  value       = google_compute_instance.this.id
}

output "public_ip" {
  description = "Ephemeral public IPv4."
  value       = google_compute_instance.this.network_interface[0].access_config[0].nat_ip
}

output "private_ip" {
  description = "Private IPv4."
  value       = google_compute_instance.this.network_interface[0].network_ip
}
