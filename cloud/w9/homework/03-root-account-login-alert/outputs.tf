output "sns_topic_arn" {
  description = "SNS Topic ARN used by the root login alarm."
  value       = aws_sns_topic.root_login.arn
}

output "cloudtrail_bucket_name" {
  description = "S3 bucket name used by CloudTrail."
  value       = aws_s3_bucket.cloudtrail.bucket
}

output "log_group_name" {
  description = "CloudWatch Log Group used by CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "root_login_alarm_name" {
  description = "CloudWatch alarm name."
  value       = aws_cloudwatch_metric_alarm.root_login.alarm_name
}

