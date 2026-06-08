data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_read" {
  statement {
    sid = "ListAssetsBucket"

    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.asset_bucket_name}"]
  }

  statement {
    sid = "ReadStaticAssets"

    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.asset_bucket_name}/*"]
  }
}

resource "aws_iam_role" "web" {
  name               = "${var.name_prefix}-web-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json

  tags = {
    Name = "${var.name_prefix}-web-role"
  }
}

resource "aws_iam_role_policy" "s3_read" {
  name   = "${var.name_prefix}-s3-read"
  role   = aws_iam_role.web.id
  policy = data.aws_iam_policy_document.s3_read.json
}

resource "aws_iam_instance_profile" "web" {
  name = "${var.name_prefix}-web-profile"
  role = aws_iam_role.web.name
}

data "cloudinit_config" "web" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    filename     = "bootstrap-web.sh"
    content = templatefile(var.user_data_template, {
      asset_bucket_name = var.asset_bucket_name
      asset_object_keys = join(",", var.asset_object_keys)
      db_endpoint       = var.db_endpoint
      db_name           = var.db_name
    })
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.web_security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.web.name
  key_name                    = var.key_name
  user_data                   = data.cloudinit_config.web.rendered

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 12
  }

  tags = {
    Name = "${var.name_prefix}-web"
  }

  depends_on = [aws_iam_role_policy.s3_read]
}
