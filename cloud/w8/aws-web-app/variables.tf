variable "aws_region" {
  description = "AWS region for the AWS web app resources."
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name used as a resource name prefix."
  type        = string
  default     = "aws-web-app"
}

variable "environment" {
  description = "Environment name used in tags and resource names."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.50.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones used for public and private subnets."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2
    error_message = "az_count must be at least 2 for a resilient RDS subnet group."
  }
}

variable "enable_nat_gateway" {
  description = "Whether private subnets should have outbound Internet access through a NAT Gateway."
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "EC2 instance type for the public web server."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Optional existing EC2 key pair name for SSH access."
  type        = string
  default     = null
}

variable "enable_ssh" {
  description = "Whether to allow SSH to the web EC2 instance."
  type        = bool
  default     = false
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH to the web EC2 instance when enable_ssh is true."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to access the web server over HTTP."
  type        = string
  default     = "0.0.0.0/0"
}

variable "db_name" {
  description = "Initial MySQL database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "RDS master username. The password is managed by RDS in Secrets Manager."
  type        = string
  default     = "admin"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Initial RDS allocated storage in GiB."
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Maximum RDS storage autoscaling size in GiB."
  type        = number
  default     = 100
}

variable "db_multi_az" {
  description = "Whether to enable Multi-AZ for RDS. Disabled by default to keep the lab cost lower."
  type        = bool
  default     = false
}

variable "db_backup_retention_period" {
  description = "Number of days to retain automated RDS backups."
  type        = number
  default     = 7
}

variable "db_deletion_protection" {
  description = "Whether to enable deletion protection for RDS."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip a final DB snapshot during destroy."
  type        = bool
  default     = true
}
