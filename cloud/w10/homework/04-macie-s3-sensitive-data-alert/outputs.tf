output "s3_bucket_name" {
  description = "S3 bucket scanned by Macie."
  value       = aws_s3_bucket.sample.bucket
}

output "aws_region" {
  description = "AWS region used by this homework."
  value       = var.aws_region
}

output "sample_s3_prefix" {
  description = "S3 prefix containing sample files."
  value       = "s3://${aws_s3_bucket.sample.bucket}/sample-files/"
}

output "sns_topic_arn" {
  description = "SNS topic receiving EventBridge Macie findings."
  value       = aws_sns_topic.macie_findings.arn
}

output "macie_job_id" {
  description = "Macie classification job ID."
  value       = aws_macie2_classification_job.s3_sensitive_data.job_id
}

output "macie_job_name" {
  description = "Macie classification job name."
  value       = aws_macie2_classification_job.s3_sensitive_data.name
}

output "eventbridge_rule_name" {
  description = "EventBridge rule that forwards Macie findings to SNS."
  value       = aws_cloudwatch_event_rule.macie_findings.name
}
