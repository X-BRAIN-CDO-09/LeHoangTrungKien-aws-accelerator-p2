output "bucket_name" {
  description = "S3 assets bucket name."
  value       = aws_s3_bucket.assets.bucket
}

output "bucket_arn" {
  description = "S3 assets bucket ARN."
  value       = aws_s3_bucket.assets.arn
}

output "asset_object_keys" {
  description = "Uploaded S3 object keys."
  value       = [for object in aws_s3_object.assets : object.key]
}

