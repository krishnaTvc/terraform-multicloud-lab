# Reading your first module

Read aws/terraform.tfvars, then aws/main.tf, then modules/aws-lab/main.tf.
Do not try to memorize all resources immediately; follow their references.

## The key Terraform words

| Word or expression | Meaning in this project |
| --- | --- |
| terraform { } | Settings for Terraform itself: required versions and backend. |
| required_providers | Provider source and permitted version range. |
| provider "aws" | Configures the AWS API client using CLI credentials and region. |
| module "lab" | Calls a reusable folder and gives this call the label lab. |
| source = "../modules/aws-lab" | Relative path from aws/ to the reusable module. |
| variable "vpc_cidr" | Declares an input named vpc_cidr. |
| type = string | Requires text; bool requires true/false. |
| description | Explains what a variable or output means. |
| var.vpc_cidr | Reads an input in the CURRENT module. |
| resource "aws_vpc" "this" | Manages a VPC; this is a local Terraform label. |
| aws_vpc.this.id | Reads its actual AWS ID and creates an implicit dependency. |
| data "aws_ami" "ubuntu" | Looks up an existing AMI rather than creating one. |
| output "public_ip" | Exposes a result to the caller or CLI. |
| module.lab.public_ip | Reads the child module's public_ip output. |
| [value] | A list; e.g. a list of subnet CIDRs or security group IDs. |
| { Name = var.name } | An object/map of key-value pairs, here AWS tags. |
| count = condition ? 1 : 0 | Creates one resource when true, none when false. |
| resource_name[0] | Selects the first instance of a resource using count. |
| condition ? yes : no | Chooses a value based on a Boolean condition. |
| null | Omits an optional value, e.g. no EC2 instance profile. |
| file(path) | Reads a local file, here the PUBLIC SSH key. |
| pathexpand(path) | Expands ~ to your home directory. |
| jsonencode(object) | Converts Terraform data into JSON for an IAM policy. |
| trimspace(text) | Removes leading/trailing whitespace from key text. |
| ${var.name} | Inserts a variable into a quoted string. |
| depends_on | Explicit ordering for dependencies not captured by a normal reference. |
| lifecycle / prevent_destroy | Blocks deletion of backend storage unless deliberately changed. |
| ~> 6.0 | Allows compatible 6.x provider releases, but not 7.x. |
| # | A comment for humans; Terraform ignores it. |

## Follow one input

aws/terraform.tfvars sets vpc_cidr = "10.20.0.0/16".
aws/variables.tf declares the input.
aws/main.tf passes vpc_cidr = var.vpc_cidr into module lab.
modules/aws-lab/variables.tf declares that module's input.
modules/aws-lab/main.tf uses cidr_block = var.vpc_cidr in aws_vpc.this.
The module does not read the root's tfvars directly; the root explicitly passes values.

## Follow one output

aws_instance.vm.public_ip -> child output "public_ip" ->
root output value module.lab.public_ip -> terraform output -raw public_ip.
A child output is not automatically printed by terraform output; root outputs expose it.

## CIDR and route basics

10.20.0.0/16 contains both 10.20.1.0/24 and 10.20.2.0/24.
10.20.1.0/24 and 10.20.2.0/24 do not overlap.
A /24 has 256 total IPv4 addresses; cloud providers reserve some of them.
Your SSH address uses /32, meaning one IPv4 address.
A route destination 0.0.0.0/0 means all IPv4 destinations; it is a ROUTE,
not an instruction to allow inbound traffic through the security group.
An AWS subnet becomes public through its internet gateway route. An EC2 instance
also needs a public IP and suitable security group rules for direct SSH access.
The private subnet still communicates over the VPC-local route, but has no
internet egress because this example does not create a NAT gateway.

## State versus provider lock versus plan

terraform.tfstate records which real resources Terraform manages.
.terraform.lock.hcl records provider versions/checksums, not cloud resource state.
lab.tfplan is a saved proposed action plan; it is not remote state.
The backend stores workload state, not your source code or saved plan artifact.
Treat state and plan files as sensitive even when using SSH keys.
