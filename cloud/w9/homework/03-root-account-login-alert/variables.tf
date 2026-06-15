variable "aws_region" {
  description = "AWS region for the root login alert homework."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "w9-root-login-alert"
}

variable "student_id" {
  description = "Student ID used in tags."
  type        = string
  default     = "XB-DN26-045"
}

variable "notification_email" {
  description = "Email address that receives SNS notifications."
  type        = string
}

variable "metric_filter_pattern" {
  description = "CloudWatch Logs metric filter pattern for root ConsoleLogin."
  type        = string
  default     = "{ ($.userIdentity.type = \"Root\") && ($.eventName = \"ConsoleLogin\") }"
}

variable "alarm_threshold" {
  description = "Metric threshold that triggers the alarm."
  type        = number
  default     = 1
}

variable "alarm_period_seconds" {
  description = "Alarm period in seconds."
  type        = number
  default     = 300
}

