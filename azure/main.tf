# Root module: sends your chosen values to the reusable child module.
module "lab" {
  source         = "../modules/azure-lab"
  name           = var.name
  location       = var.location
  vnet_cidr      = var.vnet_cidr
  subnet_cidr    = var.subnet_cidr
  vm_size        = var.vm_size
  admin_username = var.admin_username
  ssh_cidr       = var.ssh_cidr
  ssh_public_key = file(pathexpand(var.ssh_public_key_path))
}
