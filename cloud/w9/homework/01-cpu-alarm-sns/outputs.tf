output "sns_topic_arn" {
  description = "SNS Topic ARN used by the CPU alarm."
  value       = aws_sns_topic.cpu_alarm.arn
}

output "subscription_status_note" {
  description = "Reminder to confirm the SNS email subscription."
  value       = "Open ${var.notification_email} and confirm the AWS SNS subscription email."
}

output "cpu_alarm_name" {
  description = "CloudWatch alarm name."
  value       = aws_cloudwatch_metric_alarm.ec2_cpu_high.alarm_name
}

output "monitored_instance_id" {
  description = "EC2 instance ID monitored by the CPU alarm."
  value       = local.monitored_instance_id
}

output "test_instance_note" {
  description = "Note about optional CPU stress instance."
  value       = var.create_test_instance ? "Temporary CPU stress EC2 was created. Wait 5-8 minutes for CloudWatch alarm evaluation, then destroy when done." : "Monitoring an existing EC2 instance."
}
