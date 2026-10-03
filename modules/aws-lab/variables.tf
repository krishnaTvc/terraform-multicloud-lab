variable "name" {
  description = "Resource name prefix."
  type        = string
}

variable "availability_zone" {
  description = "AZ for both subnets; must belong to region."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC IPv4 CIDR."
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR inside VPC."
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR inside VPC; no NAT in this lab."
  type        = string
}

variable "instance_type" {
  description = "x86 EC2 size; example t3.micro."
  type        = string
}

variable "ssh_cidr" {
  description = "Your public IPv4 address with /32."
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key text passed by root."
  type        = string
}

variable "enable_ssm" {
  description = "Create an EC2 role with AmazonSSMManagedInstanceCore when true."
  type        = bool
}
