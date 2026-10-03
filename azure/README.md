# Azure lab: new resource group, VNet, subnet, NSG, NIC and Linux VM

This is a NEW lab based on your uploaded resource design. It does not adopt or
modify your existing rg-terraform-lab, vm-lab or their state automatically.

## Shared prerequisites

Install Terraform >= 1.10 and the cloud CLI. Commands below are for PowerShell,
your current Windows workflow. Extract the ZIP and start from its top-level folder.
Create an SSH key once if you do not already have a suitable key:

```powershell
ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/terraform-lab"
```
Choose a passphrase when prompted. Keep the private key locally. Only the .pub file
is read by Terraform. Edit ssh_public_key_path if using an existing key.
Get your current public IPv4 address from your network/router or a trusted IP
lookup and put it in ssh_cidr as IP/32. The shipped 203.0.113.10/32 is a documentation
address and will NOT grant your laptop access. Use forward slashes in Windows
paths, e.g. C:/Users/YourName/.ssh/terraform-lab.pub.

After each init, Terraform downloads providers and generates .terraform.lock.hcl;
keep that lock file in version control. Do not commit state, private keys or credentials.

## 1. Authenticate and select subscription

```powershell
az login
az account list -o table
az account set --subscription "REPLACE_WITH_SUBSCRIPTION_ID"
az account show -o table
```
For a particular tenant: az login --tenant YOUR_TENANT_ID.
Set the same subscription_id in the workload and bootstrap tfvars and backend.hcl.
Terraform uses your Azure CLI identity.

Workload permissions: Contributor at the subscription scope for creating a NEW
resource group and resources (or a suitably scoped custom role). Contributor only
on an existing unrelated resource group cannot create this new group. This code
creates no role assignments and no VM managed identity.

Backend access also needs Storage Blob Data Contributor: management-plane
Contributor alone does not grant Entra ID blob data access.

## 2. Create backend storage once

```powershell
cd bootstrap/azure
```
Edit terraform.tfvars: subscription_id, location and storage_account_name. The
storage name must be globally unique, 3-24 lowercase letters/numbers. Use a
separate backend group, not the workload group that you will later destroy.

If you already have Storage Blob Data Contributor on the subscription or backend
scope with inheritance, run the normal flow:

```powershell
terraform init
terraform fmt
terraform validate
terraform plan -out=bootstrap.tfplan
terraform apply bootstrap.tfplan
terraform output
```
This bootstrap uses Entra ID data-plane authentication and disables shared keys.
If you DO NOT already have blob data access, create just the account first:

```powershell
terraform init
terraform apply -target=azurerm_storage_account.state
```
This one-time bootstrap exception also creates its resource group dependency.
Ask the account owner to grant your CLI identity Storage Blob Data Contributor on
this new storage account. An authorized Owner/RBAC administrator can run:

```powershell
az role assignment create --assignee-object-id "YOUR_ENTRA_USER_OBJECT_ID" --assignee-principal-type User --role "Storage Blob Data Contributor" --scope "/subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_BACKEND_RG/providers/Microsoft.Storage/storageAccounts/YOUR_STORAGE_NAME"
```
For a service principal, use its object ID and --assignee-principal-type ServicePrincipal.
You can inspect your signed-in user object ID with az ad signed-in-user show --query id -o tsv.
Allow time for role propagation, then run a FULL terraform plan and apply in this
bootstrap folder to create the container. Do not use -target for normal workload runs.
Back up bootstrap/azure/terraform.tfstate securely; bootstrap remains LOCAL.

If using an EXISTING backend instead, skip creating it here, verify blob data access,
and enter its exact details in backend.hcl. Do not run this bootstrap with existing
names unless you deliberately import those objects into its state first.

## 3. Configure backend and create the workload

```powershell
cd ../../azure
Copy-Item backend.hcl.example backend.hcl
```
Edit backend.hcl to match the existing backend RG, account, container and subscription.
Use a NEW key azure/lab/terraform.tfstate, not the key of your earlier lab.
Edit azure/terraform.tfvars: name, location, VM size, CIDRs, username and SSH values.

```powershell
terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan -out=lab.tfplan
terraform apply lab.tfplan
terraform output
```
Defaults: NEW resource group rg-azure-module-lab, Ubuntu 22.04 VM, Standard_B2s,
30 GiB Standard_LRS OS disk, Standard static public IP, NIC, NSG, one VNet/subnet,
and explicit internet route table attached to the subnet. Size availability,
capacity and quota depend on your subscription/region. Standard_B4as_v2 is an
optional larger size corresponding to the size in your uploaded project.
NSG explicitly allows SSH only from your IP; Azure also has built-in default rules.
No HTTP service is installed. No admin password is written to state by this package.
Backend storage has blob versioning and seven-day soft delete; Azure backend uses
native blob locking. No storage access key belongs in backend.hcl.

## 4. Connect and clean up

```powershell
$vmIp = terraform output -raw public_ip
ssh -i "$HOME/.ssh/terraform-lab" "azureuser@$vmIp"
terraform plan -destroy
terraform destroy
```
Change azureuser if you changed admin_username. Run cleanup inside azure/.
Workload destruction deletes its resource group/resources but preserves backend
storage because it belongs to separate bootstrap state. Deallocating a VM is not
the same as deleting disks/public IPs. Do not delete the backend to clean up the VM.

## Existing state and migration

The upload creates storage but does not configure a remote backend. Do not assume
its local terraform.tfstate is unused. To move an EXISTING project's state to Blob,
back it up, add the backend to THAT project, then use terraform init -migrate-state
with a deliberate backend config. Module refactoring is a separate operation
requiring address mappings and a no-surprises plan; this ZIP does not perform it.

Reference: https://developer.hashicorp.com/terraform/language/backend/azurerm
