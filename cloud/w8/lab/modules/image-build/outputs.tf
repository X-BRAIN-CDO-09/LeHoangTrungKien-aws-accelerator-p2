output "image_uri" {
  description = "Image URI pushed to ECR."
  value       = var.image_uri
}

output "complete" {
  description = "Dependency handle for resources that must wait until the image is pushed."
  value       = terraform_data.push_demo_image.id
}
