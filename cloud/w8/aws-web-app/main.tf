module "network" {
  source = "./modules/network"

  name_prefix        = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  az_count           = var.az_count
  enable_nat_gateway = var.enable_nat_gateway
}

module "storage" {
  source = "./modules/storage"

  name_prefix      = local.name_prefix
  bucket_name      = local.asset_bucket_name
  asset_source_dir = "${path.module}/assets"
}

module "security" {
  source = "./modules/security"

  name_prefix       = local.name_prefix
  vpc_id            = module.network.vpc_id
  allowed_http_cidr = var.allowed_http_cidr
  enable_ssh        = var.enable_ssh
  ssh_cidr          = var.ssh_cidr
}

module "database" {
  source = "./modules/database"

  name_prefix                = local.name_prefix
  private_subnet_ids         = module.network.private_subnet_ids
  db_security_group_id       = module.security.db_security_group_id
  db_name                    = var.db_name
  db_username                = var.db_username
  db_instance_class          = var.db_instance_class
  db_allocated_storage       = var.db_allocated_storage
  db_max_allocated_storage   = var.db_max_allocated_storage
  db_multi_az                = var.db_multi_az
  db_backup_retention_period = var.db_backup_retention_period
  db_deletion_protection     = var.db_deletion_protection
  db_skip_final_snapshot     = var.db_skip_final_snapshot
}

module "compute" {
  source = "./modules/compute"

  name_prefix           = local.name_prefix
  instance_type         = var.instance_type
  public_subnet_id      = module.network.public_subnet_ids[0]
  web_security_group_id = module.security.web_security_group_id
  key_name              = var.key_name
  asset_bucket_name     = module.storage.bucket_name
  asset_object_keys     = module.storage.asset_object_keys
  db_endpoint           = module.database.endpoint
  db_name               = var.db_name
  user_data_template    = "${path.module}/user_data.sh.tftpl"

  depends_on = [module.storage, module.database]
}

