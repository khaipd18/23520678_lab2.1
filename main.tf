module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.18.0.0/16"
  public_subnet_cidr  = "10.18.1.0/24"
  private_subnet_cidr = "10.18.2.0/24"
}

module "security_groups" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
  my_ip  = var.my_ip
}

module "ec2" {
  source            = "./modules/ec2"
  public_subnet_id  = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id
  public_sg_id      = module.security_groups.public_sg_id
  private_sg_id     = module.security_groups.private_sg_id
  key_name          = var.key_name
}