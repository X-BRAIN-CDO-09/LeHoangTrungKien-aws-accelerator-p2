resource "aws_ecr_repository" "demo" {
  name         = "demo-app-${var.suffix}"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.name_prefix}-demo-app"
  }
}
