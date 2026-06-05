resource "tls_private_key" "ec2" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "generated_private_key" {
  content         = tls_private_key.ec2.private_key_openssh
  filename        = "${path.module}/.generated/${local.name_prefix}.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "generated" {
  key_name   = "${var.project_name}-${local.suffix}-key"
  public_key = tls_private_key.ec2.public_key_openssh
}

locals {
  suffix      = substr(sha256(tls_private_key.ec2.public_key_openssh), 0, 8)
  name_prefix = "${var.project_name}-${local.suffix}"
  key_name    = coalesce(var.key_name, aws_key_pair.generated.key_name)
}

module "network" {
  source = "./modules/network"

  name_prefix = local.name_prefix
}

module "security" {
  source = "./modules/security"

  name_prefix   = local.name_prefix
  vpc_id        = module.network.vpc_id
  app_node_port = var.app_node_port
  enable_ssh    = var.enable_ssh
  ssh_cidr      = var.ssh_cidr
}

module "compute" {
  source = "./modules/compute"

  name_prefix        = local.name_prefix
  instance_type      = var.instance_type
  subnet_id          = module.network.public_subnet_ids[0]
  security_group_ids = [module.security.ec2_security_group_id]
  key_name           = local.key_name
  app_image          = var.app_image
  app_node_port      = var.app_node_port
  user_data_template = "${path.module}/user_data.sh.tftpl"
}

module "alb" {
  source = "./modules/alb"

  name_prefix           = local.name_prefix
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  target_instance_id    = module.compute.instance_id
  app_node_port         = var.app_node_port

  depends_on = [module.compute]
}
