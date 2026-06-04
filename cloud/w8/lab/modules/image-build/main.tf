resource "terraform_data" "push_demo_image" {
  triggers_replace = [
    filesha256("${var.app_dir}/Dockerfile"),
    filesha256("${var.app_dir}/index.html"),
    filesha256("${var.app_dir}/styles.css"),
    var.image_uri
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.ecr_registry}
      docker build --platform linux/amd64 -t ${var.image_uri} ${var.app_dir}
      docker push ${var.image_uri}
    EOT
  }
}
