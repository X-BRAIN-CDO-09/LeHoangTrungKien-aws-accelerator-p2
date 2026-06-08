variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "db_security_group_id" {
  description = "Security group ID attached to RDS."
  type        = string
}

variable "db_name" {
  description = "Initial MySQL database name."
  type        = string
}

variable "db_username" {
  description = "RDS master username."
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Maximum storage autoscaling size in GiB."
  type        = number
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ."
  type        = bool
}

variable "db_backup_retention_period" {
  description = "Automated backup retention in days."
  type        = number
}

variable "db_deletion_protection" {
  description = "Whether to enable deletion protection."
  type        = bool
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip a final snapshot on destroy."
  type        = bool
}

