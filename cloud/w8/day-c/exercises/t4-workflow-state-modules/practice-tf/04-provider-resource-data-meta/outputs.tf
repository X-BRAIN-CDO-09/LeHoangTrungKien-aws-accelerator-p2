/*
TODO:
- Output values from the resource or the data source.
*/

output "bucket_name" {
  description = "Name of the example bucket."
  value       = aws_s3_bucket.example.bucket
}

output "account_id" {
  description = "AWS account ID from the data source."
  value       = data.aws_caller_identity.current.account_id
}
