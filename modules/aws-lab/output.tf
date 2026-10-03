output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "Public subnet ID."
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "Private subnet ID."
  value       = aws_subnet.private.id
}

output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.vm.id
}

output "public_ip" {
  description = "EC2 public IPv4; can change after stop/start."
  value       = aws_instance.vm.public_ip
}

output "private_ip" {
  description = "EC2 private IPv4."
  value       = aws_instance.vm.private_ip
}

output "iam_role_name" {
  description = "Optional EC2 role name."
  value       = var.enable_ssm ? aws_iam_role.vm[0].name : null
}
