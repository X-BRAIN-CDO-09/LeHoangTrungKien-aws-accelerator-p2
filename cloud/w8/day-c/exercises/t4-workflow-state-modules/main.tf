module "naming" {
  source = "./modules/naming"

  project_name = var.project_name
  environment  = var.environment
  services     = var.services
  tags         = var.tags
}

