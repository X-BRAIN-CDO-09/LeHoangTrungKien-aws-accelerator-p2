variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for the web server."
  type        = string
}

variable "web_security_group_id" {
  description = "Security group ID attached to the web server."
  type        = string
}

variable "key_name" {
  description = "Optional EC2 key pair name."
  type        = string
  default     = null
}

variable "asset_bucket_name" {
  description = "S3 bucket containing static assets."
  type        = string
}

variable "asset_object_keys" {
  description = "S3 asset object keys. Used to order EC2 bootstrap after asset upload."
  type        = list(string)
}

variable "db_endpoint" {
  description = "RDS endpoint used as non-secret runtime metadata."
  type        = string
}

variable "db_name" {
  description = "Database name used as non-secret runtime metadata."
  type        = string
}

variable "user_data_template" {
  description = "Path to the user data template."
  type        = string
}

