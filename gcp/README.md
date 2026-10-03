# GCP prototype — save for later

This folder is a real Terraform example with placeholders, not a deployed GCP lab.
No billing/project/API enablement is created here. Do not run apply until you have
chosen to practice GCP and reviewed costs and access.

Structure matches AWS/Azure: root main.tf calls ../modules/gcp-lab; variables.tf
accepts settings; terraform.tfvars supplies values; output.tf exposes IPs.

Planned resources: custom global VPC, regional subnet, SSH firewall rule targeting
the VM tag, Ubuntu 24.04 Compute Engine VM with ephemeral public IPv4 and disk.
GCP creates default routes automatically. There is no Azure-style resource group,
no separately provisioned NIC, and no application IAM binding in this prototype.
VM SSH metadata is used; organization policies requiring OS Login may require
changing this module. No application service account is requested. No private subnet,
NAT gateway or web app is included.

## Future setup (PowerShell)

Install gcloud and Terraform >= 1.10. Have an existing billing-enabled project.
Enable compute.googleapis.com for the workload and storage.googleapis.com for the
backend; ask an authorized project admin if you cannot enable APIs. Use a suitably
scoped identity: Compute Network Admin for network/firewall, Compute Instance
Admin (v1) for VM operations, and Storage Admin for backend creation or equivalent
custom permissions. Backend reads/writes need Storage Object Admin on its bucket.
Project policies, service usage permissions and service account requirements may
require additional permissions; gcloud login alone does not grant them.

```powershell
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
```
Terraform uses Application Default Credentials (ADC); the CLI login is separate.
Generate/use the same RSA public SSH key described in the other cloud READMEs.
Edit project_id, region/zone and bucket_name in bootstrap/gcp/terraform.tfvars.

```powershell
cd bootstrap/gcp
terraform init
terraform validate
terraform plan -out=bootstrap.tfplan
terraform apply bootstrap.tfplan
terraform output
cd ../../gcp
Copy-Item backend.hcl.example backend.hcl
```
Copy the created bucket name to backend.hcl. Bootstrap state stays LOCAL: preserve
it securely. The state bucket uses uniform access, versioning and public access
prevention. GCS supports native state locking.

Edit gcp/terraform.tfvars with your project, zone, username, public key path and
public IPv4/32. Only after deciding to deploy:

```powershell
terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan -out=lab.tfplan
terraform apply lab.tfplan
$vmIp = terraform output -raw public_ip
ssh -i "$HOME/.ssh/terraform-lab" "gcpuser@$vmIp"
```
Cleanup from gcp/: terraform destroy. Backend bucket remains protected. Defaults
are e2-micro with 20 GiB disk; no claim of free-tier eligibility is made.

Reference: https://developer.hashicorp.com/terraform/language/backend/gcs
