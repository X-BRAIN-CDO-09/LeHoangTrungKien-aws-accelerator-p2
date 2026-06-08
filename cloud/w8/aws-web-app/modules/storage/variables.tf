variable "name_prefix" {
  description = "Resource name prefix."
  type        = string
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name."
  type        = string
}

variable "asset_source_dir" {
  description = "Local directory containing static assets to upload."
  type        = string
}

