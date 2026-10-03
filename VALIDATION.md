# Validation performed

- Terraform 1.13.5: terraform fmt -recursive completed successfully.
- All 51 Terraform/configuration HCL files parsed successfully with python-hcl2.
- All three root tfvars sets match their declared variables.
- All three root module calls match the child module inputs.
- Archive excludes provider binaries, .terraform directories, Git history,
  existing passwords, private keys and Terraform state/plan files.

Provider initialization without a backend succeeded for AWS, Azure and GCP.
Full terraform validate could not complete in this execution environment:
Azure/Google provider startup was blocked by local Unix socket restrictions;
AWS cached provider checksum verification also failed here. These are not passed
provider schema checks. Generated validation caches/lock files were omitted.

Run terraform init, terraform validate and review terraform plan on your own
machine as described in each cloud README. Availability, quota, IAM/RBAC,
organization policy and costs have not been checked against your accounts.
No cloud plan/apply or live deployment was run.
