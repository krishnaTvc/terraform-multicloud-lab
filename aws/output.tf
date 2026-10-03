output "vpc_id" {
  description = "VPC ID."
  value       = module.lab.vpc_id
}

output "public_subnet_id" {
  description = "Public subnet ID."
  value       = module.lab.public_subnet_id
}

output "private_subnet_id" {
  description = "Private subnet ID."
  value       = module.lab.private_subnet_id
}

output "instance_id" {
  description = "EC2 instance ID."
  value       = module.lab.instance_id
}

output "public_ip" {
  description = "EC2 public IPv4; can change after stop/start."
  value       = module.lab.public_ip
}

output "private_ip" {
  description = "EC2 private IPv4."
  value       = module.lab.private_ip
}

output "iam_role_name" {
  description = "Optional EC2 role name."
  value       = module.lab.iam_role_name
}
