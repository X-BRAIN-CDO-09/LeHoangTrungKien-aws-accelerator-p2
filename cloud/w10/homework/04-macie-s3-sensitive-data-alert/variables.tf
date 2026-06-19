variable "aws_region" {
  description = "AWS region for the Macie S3 sensitive data homework."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "w10-macie-s3-alert"
}

variable "student_id" {
  description = "Student ID used in tags."
  type        = string
  default     = "XB-DN26-045"
}

variable "notification_email" {
  description = "Email address that receives SNS notifications from EventBridge."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.notification_email)) && var.notification_email != "your-email@example.com"
    error_message = "notification_email must be a real email address, not the example placeholder."
  }
}

variable "bucket_name_suffix" {
  description = "Optional suffix for globally unique S3 bucket name. Leave empty to use AWS account ID."
  type        = string
  default     = ""
}

variable "sample_data_dir" {
  description = "Local directory containing sample files that Terraform uploads to S3 for Macie scanning."
  type        = string
  default     = "sample-data"
}

variable "macie_job_name" {
  description = "Macie classification job name."
  type        = string
  default     = "w10-sensitive-data-scan-v2"
}

variable "macie_finding_publishing_frequency" {
  description = "How often Macie publishes findings to EventBridge."
  type        = string
  default     = "FIFTEEN_MINUTES"

  validation {
    condition = contains([
      "FIFTEEN_MINUTES",
      "ONE_HOUR",
      "SIX_HOURS",
    ], var.macie_finding_publishing_frequency)
    error_message = "Allowed values: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."
  }
}
