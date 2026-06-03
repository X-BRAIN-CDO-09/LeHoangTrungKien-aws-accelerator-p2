/*
TODO:
- Add one resource block, one data source block, and at least one meta-argument example.
*/

resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name

  tags = local.common_tags
}

data "aws_caller_identity" "current" {}
