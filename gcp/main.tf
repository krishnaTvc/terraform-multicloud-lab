# Root module: sends your chosen values to the reusable child module.
module "lab" {
  source         = "../modules/gcp-lab"
  name           = var.name
  region         = var.region
  zone           = var.zone
  subnet_cidr    = var.subnet_cidr
  machine_type   = var.machine_type
  admin_username = var.admin_username
  ssh_cidr       = var.ssh_cidr
  ssh_public_key = file(pathexpand(var.ssh_public_key_path))
}
