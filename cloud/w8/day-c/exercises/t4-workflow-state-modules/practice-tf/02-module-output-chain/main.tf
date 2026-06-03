module "VPC" {
  source = "./modules/VPC"
  project_name = var.project_name
  vpc_cidr  = var.vpc_cidr
  vpc_cidr_subnet     = var.vpc_cidr_subnet
  sg_name = var.sg_name
}
