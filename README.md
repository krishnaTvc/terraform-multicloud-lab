# Simple Terraform multi-cloud module lab

Start with AWS; use Azure separately. GCP is a saved prototype.
No cloud resources were deployed while building this package.

## Folder map

| Folder | What it does |
| --- | --- |
| aws/ | Root module you run for AWS |
| azure/ | Root module you run for Azure |
| gcp/ | Prototype root module for GCP |
| modules/aws-lab/ | Reusable AWS network + EC2 + optional instance IAM role |
| modules/azure-lab/ | Reusable Azure resource group + network + Linux VM |
| modules/gcp-lab/ | Prototype GCP network + Linux VM |
| bootstrap/aws/ | Creates S3 backend using its own LOCAL state |
| bootstrap/azure/ | Creates dedicated Azure backend using its own LOCAL state |
| bootstrap/gcp/ | Prototype GCS backend using its own LOCAL state |

Run Terraform inside one root folder, never from this top-level folder or modules/.
Each cloud has independent state. Deploying AWS does not deploy Azure or GCP.
Keep the relative folder layout unchanged when extracting the ZIP.

## Why modules are appropriate

A module groups resources that belong together. One lab module per cloud is an
appropriate first step; later split into networking and compute modules when
those parts need independent reuse. These are three cloud-specific implementations,
not one universal resource definition. AWS, Azure, and GCP APIs differ.

The value flow is:
1. terraform.tfvars provides your actual choices.
2. Root variables.tf declares names and types.
3. Root main.tf calls the child module and passes var values.
4. Child variables.tf receives them; child main.tf creates the resources.
5. Child output.tf returns values; root output.tf exposes them in terraform output.

## File meanings

| File | Purpose |
| --- | --- |
| main.tf | Root: module call. Child: resources and their connections. |
| variables.tf | Inputs: type and explanation, not credentials. |
| terraform.tfvars | Editable region, size, names, CIDRs and key path. |
| output.tf | Results such as public IP and resource IDs. |
| providers.tf | Cloud provider configuration and authentication context. |
| versions.tf | Terraform/provider versions and root backend type. |
| backend.hcl.example | Template for backend location; copy to backend.hcl. |
| .terraform.lock.hcl | Generated provider version/checksum lock; commit this file. |

Terraform reads all .tf files in the current directory together. File names do not
control execution order. Resource references establish dependencies. Neither a
.tfvars file nor a child module can configure the root backend with var expressions.
The backend must already exist when terraform init runs; depends_on cannot create
it during initialization. Therefore bootstrap first, workload second.

## Cloud equivalents

| Azure | AWS | GCP |
| --- | --- | --- |
| Resource group | No direct equivalent; use tags | Existing project is a broader boundary |
| VNet | VPC | VPC network (global) |
| Subnet (regional) | Subnet (one AZ) | Subnet (regional) |
| NSG | Security group (not identical behavior) | VPC firewall rules |
| Route table / system routes | Route tables + internet gateway | VPC routes / default internet gateway |
| NIC | EC2 primary ENI created automatically here | VM network interface |
| Linux VM | EC2 instance | Compute Engine VM |
| VM size | Instance type | Machine type |
| Blob state backend | S3 state backend | GCS state backend |
| Managed identity (not needed in Azure lab) | Optional EC2 instance role | No application service account requested |

## What changed from the uploaded Azure project

The uploaded main.tf used a data source for an already existing resource group;
it did not create that group. Its providers.tf had no azurerm backend block, so
creating Blob storage there did not itself enable remote state. This package
adds a real backend setup, separates its lifetime, and creates a NEW lab group.
It uses an explicit route table and SSH keys instead of the uploaded password.
Git history, cached providers, passwords and state files were intentionally not copied.
If the uploaded VM password is still in use, change it; do not commit credentials.

This is a FRESH lab, not an automatic migration of your existing Azure resources.
Do not copy these files onto your old state or point the new backend at the old
state key. Existing resources require planned imports/moved blocks and review of
terraform plan before refactoring. Keep the old project and state intact.

## Learning limits and cleanup

Single VM per cloud, SSH only, no web-server installation, no HA, no load balancer.
AWS adds an empty private subnet with no NAT to avoid NAT Gateway costs.
Only port 22 is allowed by the explicit SSH rule; no HTTP app is deployed.
VMs, disks, public IPv4 addresses, state storage and retained versions can cost money.
Small example sizes are not a promise of free usage or enough RAM for Kubernetes.
Use terraform destroy from the cloud root after practice. This retains backend
storage. Bootstrap prevent_destroy is deliberate; do not destroy the backend
while a workload still relies on it. Preserve bootstrap local state securely.

## Official references

- https://developer.hashicorp.com/terraform/language/modules/develop
- https://developer.hashicorp.com/terraform/language/backend/s3
- https://developer.hashicorp.com/terraform/language/backend/azurerm
- https://developer.hashicorp.com/terraform/language/backend/gcs
- https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-permissions.html
