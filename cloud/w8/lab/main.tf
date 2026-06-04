data "aws_caller_identity" "current" {}

resource "terraform_data" "preflight" {
  input = {
    aws_region = var.aws_region
    app_dir    = "${path.module}/demo-app"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail

      command -v aws >/dev/null || {
        echo "ERROR: aws CLI is required on the local machine."
        exit 1
      }

      aws sts get-caller-identity >/dev/null || {
        echo "ERROR: AWS credentials are not configured or are invalid."
        exit 1
      }

      command -v docker >/dev/null || {
        echo "ERROR: docker CLI is required on the local machine."
        echo "If you are using WSL2, enable Docker Desktop WSL integration for this distro."
        exit 1
      }

      docker info >/dev/null || {
        echo "ERROR: Docker daemon is not reachable."
        echo "Start Docker Desktop and enable WSL integration, then run terraform apply again."
        exit 1
      }

      test -f "${path.module}/demo-app/Dockerfile" || {
        echo "ERROR: demo-app/Dockerfile was not found."
        exit 1
      }
    EOT
  }
}

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

  depends_on = [terraform_data.preflight]
}

locals {
  suffix       = substr(sha256(tls_private_key.ec2.public_key_openssh), 0, 8)
  name_prefix  = "${var.project_name}-${local.suffix}"
  ecr_registry = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  key_name     = coalesce(var.key_name, aws_key_pair.generated.key_name)
}

module "network" {
  source = "./modules/network"

  name_prefix = local.name_prefix

  depends_on = [terraform_data.preflight]
}

module "ecr" {
  source = "./modules/ecr"

  name_prefix = local.name_prefix
  suffix      = local.suffix

  depends_on = [terraform_data.preflight]
}

module "image_build" {
  source = "./modules/image-build"

  aws_region   = var.aws_region
  ecr_registry = local.ecr_registry
  image_uri    = "${module.ecr.repository_url}:${var.app_image_tag}"
  app_dir      = "${path.module}/demo-app"
}

module "security" {
  source = "./modules/security"

  name_prefix   = local.name_prefix
  vpc_id        = module.network.vpc_id
  app_node_port = var.app_node_port
  enable_ssh    = var.enable_ssh
  ssh_cidr      = var.ssh_cidr

  depends_on = [terraform_data.preflight]
}

module "compute" {
  source = "./modules/compute"

  name_prefix          = local.name_prefix
  aws_region           = var.aws_region
  instance_type        = var.instance_type
  subnet_id            = module.network.public_subnet_ids[0]
  security_group_ids   = [module.security.ec2_security_group_id]
  key_name             = local.key_name
  ecr_registry         = local.ecr_registry
  app_image            = module.image_build.image_uri
  app_node_port        = var.app_node_port
  user_data_template   = "${path.module}/user_data.sh.tftpl"
  image_build_complete = module.image_build.complete
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
