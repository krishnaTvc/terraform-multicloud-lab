# AWS lab: VPC, public/private subnets, route tables and EC2

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

## 1. Authenticate and verify the account

```powershell
aws configure
aws sts get-caller-identity
```
Enter your IAM identity's access key/secret locally, region eu-north-1 and output json.
No keys belong in .tf files or tfvars. Temporary credentials also need the session
token; AWS SSO is another option if your organization provides it.
CLI authentication supplies Terraform credentials, but does not grant permissions.

Your Terraform identity needs permissions to create/read/update/delete the VPC,
subnets, internet gateway, routes, security group, key pair and EC2/EBS resources,
plus EC2 Describe calls. With enable_ssm=true it also needs IAM role, attachment,
instance-profile operations and iam:PassRole on the lab role. Bootstrap additionally
needs S3 bucket, policy, versioning, encryption and public-access settings operations.
Have the account owner grant these scoped permissions; the code does not grant
permissions to the identity running it. Set enable_ssm=false to omit instance IAM.

The optional EC2 role only attaches AmazonSSMManagedInstanceCore. It gives the VM
Systems Manager permissions, not AdministratorAccess or Terraform backend access.
SSM additionally requires a running SSM agent and reachable SSM endpoints over HTTPS.
SSH works independently of SSM. No IAM user/access keys are created.

## 2. Create the remote-state bucket once

```powershell
cd bootstrap/aws
```
Edit terraform.tfvars: pick a globally unique bucket name, for example a name
containing your account ID and a chosen suffix. Keep region eu-north-1.

```powershell
terraform init
terraform fmt
terraform validate
terraform plan -out=bootstrap.tfplan
terraform apply bootstrap.tfplan
terraform output
cd ../../aws
Copy-Item backend.hcl.example backend.hcl
```
Edit backend.hcl: paste the exact bucket name and matching bucket region.
The key aws/lab/terraform.tfstate belongs only to this NEW AWS lab.
The bootstrap has LOCAL state: back up bootstrap/aws/terraform.tfstate securely.
The S3 bucket is private, encrypted, versioned and protected from Terraform deletion.
S3 native locking is enabled using use_lockfile=true; no DynamoDB table is needed.

Backend identity permissions: s3:ListBucket on the bucket; s3:GetObject and
s3:PutObject on aws/lab/terraform.tfstate; s3:GetObject, s3:PutObject and
s3:DeleteObject on aws/lab/terraform.tfstate.tflock. See the official S3 backend
reference for a scoped JSON policy. The EC2 role is not used to authenticate this backend.

## 3. Create the workload

Edit aws/terraform.tfvars: name, region, availability_zone, CIDRs, instance_type,
ssh_cidr and ssh_public_key_path. Region in backend.hcl describes the STATE bucket;
region in tfvars describes the WORKLOAD. These need not match, but do match here.
Choose an AZ available in your account; its name must belong to your chosen region:

```powershell
aws ec2 describe-availability-zones --region eu-north-1 --query "AvailabilityZones[?State=='available'].ZoneName" --output table
terraform init -backend-config=backend.hcl
terraform fmt -recursive
terraform validate
terraform plan -out=lab.tfplan
terraform apply lab.tfplan
terraform output
```
Check plan before applying. Defaults: one Ubuntu 24.04 x86 EC2 t3.micro, 16 GiB
encrypted gp3 disk, one public subnet and one empty private subnet. Both subnets
have separate route tables. Only the public table has an internet gateway route.
No NAT, no Elastic IP, no private EC2 and no application bucket are added.
For larger Kubernetes practice, choose an x86 size such as t3.large after checking
availability and cost. ARM t4g sizes do not match this module's x86 AMI.

## 4. Connect and inspect

```powershell
$vmIp = terraform output -raw public_ip
ssh -i "$HOME/.ssh/terraform-lab" "ubuntu@$vmIp"
```
EC2 public IPv4 can change after stopping/starting the instance. Use terraform
refresh through a normal plan/apply before relying on stored output after external changes.
Inside Ubuntu you can run uptime, free -h and df -h or your health-check script.

## 5. Clean up the workload

```powershell
terraform plan -destroy
terraform destroy
```
Run inside aws/. Backend storage is retained. Stopping EC2 alone does not delete
EBS or backend costs. Keep the state bucket while you need its state/history.

## How the module call works

main.tf sends var.vpc_cidr to modules/aws-lab/variables.tf. That module uses
var.vpc_cidr in aws_vpc.this. Its subnet references aws_vpc.this.id, so Terraform
creates the VPC first automatically. output.tf returns the EC2 public IP through
module.lab.public_ip. You edit root tfvars, not the module, to reuse the lab.

Reference: https://developer.hashicorp.com/terraform/language/backend/s3
