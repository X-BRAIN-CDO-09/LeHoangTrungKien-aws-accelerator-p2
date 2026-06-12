data "aws_vpc" "selected" {
  count = var.create_test_instance ? 1 : 0

  id      = var.vpc_id
  default = var.vpc_id == null ? true : null
}

data "aws_subnets" "selected" {
  count = var.create_test_instance ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected[0].id]
  }
}

data "aws_ami" "amazon_linux_2023" {
  count = var.create_test_instance ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_sns_topic" "cpu_alarm" {
  name = "${local.name_prefix}-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.cpu_alarm.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_security_group" "cpu_stress" {
  count = var.create_test_instance ? 1 : 0

  name        = "${local.name_prefix}-stress-sg"
  description = "Outbound-only security group for temporary CPU alarm test EC2."
  vpc_id      = data.aws_vpc.selected[0].id

  egress {
    description = "Allow outbound traffic."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "cpu_stress" {
  count = var.create_test_instance ? 1 : 0

  ami                         = data.aws_ami.amazon_linux_2023[0].id
  instance_type               = var.test_instance_type
  subnet_id                   = coalesce(var.subnet_id, data.aws_subnets.selected[0].ids[0])
  vpc_security_group_ids      = [aws_security_group.cpu_stress[0].id]
  associate_public_ip_address = true
  monitoring                  = true

  user_data_replace_on_change = true
  user_data                   = file("${path.module}/stress-cpu-user-data.sh")

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${local.name_prefix}-stress-test"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "${local.name_prefix}-${local.monitored_instance_id}"
  alarm_description   = "Send email when EC2 CPUUtilization is greater than ${var.cpu_threshold}% for ${var.evaluation_periods} consecutive minutes."
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.cpu_threshold
  evaluation_periods  = var.evaluation_periods
  datapoints_to_alarm = var.evaluation_periods
  period              = var.period_seconds
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = local.monitored_instance_id
  }

  alarm_actions = [
    aws_sns_topic.cpu_alarm.arn,
  ]

  ok_actions = [
    aws_sns_topic.cpu_alarm.arn,
  ]

  lifecycle {
    precondition {
      condition     = var.create_test_instance || var.instance_id != null
      error_message = "Set instance_id for an existing EC2, or set create_test_instance = true."
    }
  }
}
