# Root module: sends your chosen values to the reusable child module.
module "lab" {
  source              = "../modules/aws-lab"
  name                = var.name
  availability_zone   = var.availability_zone
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  instance_type       = var.instance_type
  ssh_cidr            = var.ssh_cidr
  ssh_public_key      = file(pathexpand(var.ssh_public_key_path))
  enable_ssm          = var.enable_ssm
}
