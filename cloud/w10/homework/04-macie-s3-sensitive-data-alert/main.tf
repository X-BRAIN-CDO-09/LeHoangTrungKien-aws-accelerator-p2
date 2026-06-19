resource "aws_s3_bucket" "sample" {
  bucket        = local.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "sample" {
  bucket                  = aws_s3_bucket.sample.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "sample" {
  bucket = aws_s3_bucket.sample.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sample" {
  bucket = aws_s3_bucket.sample.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "sample_files" {
  for_each = local.sample_files

  bucket       = aws_s3_bucket.sample.id
  key          = "sample-files/${each.value}"
  source       = "${path.module}/${var.sample_data_dir}/${each.value}"
  etag         = filemd5("${path.module}/${var.sample_data_dir}/${each.value}")
  content_type = "text/plain"

  depends_on = [
    aws_s3_bucket_public_access_block.sample,
    aws_s3_bucket_server_side_encryption_configuration.sample,
  ]
}

resource "aws_sns_topic" "macie_findings" {
  name = "${var.project_name}-findings-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.macie_findings.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

data "aws_iam_policy_document" "sns_allow_eventbridge" {
  statement {
    sid    = "AllowEventBridgePublishMacieFindings"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sns:Publish"]

    resources = [aws_sns_topic.macie_findings.arn]
  }
}

resource "aws_sns_topic_policy" "macie_findings" {
  arn    = aws_sns_topic.macie_findings.arn
  policy = data.aws_iam_policy_document.sns_allow_eventbridge.json
}

resource "aws_macie2_account" "this" {
  finding_publishing_frequency = var.macie_finding_publishing_frequency
  status                       = "ENABLED"
}

resource "time_sleep" "wait_for_macie_service_role" {
  create_duration = "180s"

  depends_on = [aws_macie2_account.this]
}

resource "aws_macie2_custom_data_identifier" "lab_secret" {
  name                   = "${var.project_name}-lab-secret"
  description            = "Detect fake lab-only sensitive strings for W10 Macie homework."
  regex                  = "CONFIDENTIAL_CUSTOMER_SECRET_[A-Z0-9]{24}"
  keywords               = ["confidential", "customer", "secret", "api_key"]
  maximum_match_distance = 100

  depends_on = [time_sleep.wait_for_macie_service_role]
}

resource "aws_macie2_classification_job" "s3_sensitive_data" {
  job_type                   = "ONE_TIME"
  name                       = var.macie_job_name
  sampling_percentage        = 100
  custom_data_identifier_ids = [aws_macie2_custom_data_identifier.lab_secret.id]

  s3_job_definition {
    bucket_definitions {
      account_id = data.aws_caller_identity.current.account_id
      buckets    = [aws_s3_bucket.sample.bucket]
    }
  }

  depends_on = [
    aws_macie2_custom_data_identifier.lab_secret,
    aws_s3_object.sample_files,
  ]
}

resource "aws_cloudwatch_event_rule" "macie_findings" {
  name        = "${var.project_name}-macie-findings"
  description = "Capture Amazon Macie findings and forward them to SNS email."

  event_pattern = jsonencode({
    source      = ["aws.macie"]
    detail-type = ["Macie Finding"]
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.macie_findings.name
  target_id = "send-macie-finding-to-sns"
  arn       = aws_sns_topic.macie_findings.arn

  depends_on = [aws_sns_topic_policy.macie_findings]
}
