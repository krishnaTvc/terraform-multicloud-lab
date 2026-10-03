# 1. Network: AWS has no Azure-style resource group. Tags group this lab.
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = var.name }
}
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-igw" }
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.name}-public" }
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone
  tags              = { Name = "${var.name}-private" }
}
# 2. A public subnet needs a route to the internet gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = { Name = "${var.name}-public-rt" }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
# Private route table has the automatic VPC-local route only; no internet/NAT.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name}-private-rt" }
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
# 3. Security group: SSH from your IP, outbound traffic allowed.
resource "aws_security_group" "vm" {
  name        = "${var.name}-sg"
  description = "SSH access for lab EC2"
  vpc_id      = aws_vpc.this.id
  ingress {
    description = "SSH from your public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# 4. Optional IAM instance role. This is NOT the CLI/Terraform user.
resource "aws_iam_role" "vm" {
  count = var.enable_ssm ? 1 : 0
  name  = "${var.name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy_attachment" "ssm" {
  count      = var.enable_ssm ? 1 : 0
  role       = aws_iam_role.vm[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "vm" {
  count = var.enable_ssm ? 1 : 0
  name  = "${var.name}-profile"
  role  = aws_iam_role.vm[0].name
}
# 5. Upload your PUBLIC key; Terraform does not generate private keys.
resource "aws_key_pair" "vm" {
  key_name   = "${var.name}-key"
  public_key = var.ssh_public_key
}
# Canonical's official Ubuntu 24.04 x86 image in the chosen region.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# 6. EC2 creates its primary network interface automatically.
resource "aws_instance" "vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.vm.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.vm.key_name
  iam_instance_profile        = var.enable_ssm ? aws_iam_instance_profile.vm[0].name : null
  metadata_options {
    http_tokens = "required"
  }
  root_block_device {
    volume_size = 16
    volume_type = "gp3"
    encrypted   = true
  }
  tags       = { Name = "${var.name}-vm" }
  depends_on = [aws_route_table_association.public, aws_iam_role_policy_attachment.ssm]
}
