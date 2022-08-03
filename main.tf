resource "aws_iam_policy" "sentinel_allow_kms" {
  name        = "AllowSentinelKMS"
  description = "Policy to allow sentinel to encrypt and decrypt data with kms key"

  policy = templatefile(
    "${path.module}/iam_policies/allow-sentinel-kms.tpl.json",
    {
      account_id = var.account_id
    }
  )
}

resource "aws_iam_policy" "sentinel_allow_sqs" {
  name        = "AllowSentinelSQS"
  description = "Policy to allow sentinel to get and delete messages in SQS"

  policy = templatefile(
    "${path.module}/iam_policies/allow-sentinel-sqs.tpl.json",
    {
      sqs_queue_arn = aws_sqs_queue.sentinel.arn
    }
  )
}

resource "aws_iam_role" "sentinel" {
  name = "MicrosoftSentinelRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        "Principal" : {
          "AWS" : "${var.sentinel_servcie_account_id}"
        },
        "Condition" : {
          "StringEquals" : {
            "sts:ExternalId" : "${var.sentinel_workspace_id}"
          }
        }
      }
    ]
  })
}

locals {
  sentinel_policies = [
    "AmazonSQSReadOnlyAccess",
    "AmazonS3ReadOnlyAccess",
    aws_iam_policy.sentinel_allow_kms.name,
    aws_iam_policy.sentinel_allow_sqs.name,
  ]
}

data "aws_iam_policy" "sentinel" {
  count = length(local.sentinel_policies)
  name  = local.sentinel_policies[count.index]

  depends_on = [
    aws_iam_policy.sentinel_allow_kms,
    aws_iam_policy.sentinel_allow_sqs,
  ]
}

resource "aws_iam_role_policy_attachment" "sentinel" {
  count      = length(local.sentinel_policies)
  role       = aws_iam_role.sentinel.name
  policy_arn = data.aws_iam_policy.sentinel[count.index].arn
}

# SQS queue
resource "aws_sqs_queue" "sentinel" {
  name = var.queue_name

  sqs_managed_sse_enabled = true

  policy = templatefile("${path.module}/iam_policies/allow-sqs-s3.tpl.json",
    {
      queue_name = var.queue_name
      bucket_arn = aws_s3_bucket.sentinel_logs.arn
  })
}


# S3 bucket
resource "aws_s3_bucket" "sentinel_logs" {
  bucket = var.sentinel_bucket_name
  lifecycle {
    # prevent_destroy = true
  }
}


## Set the bucket ACL private.
resource "aws_s3_bucket_acl" "sentinel_logs" {
  bucket = aws_s3_bucket.sentinel_logs.id
  acl    = "private"
}

## Block public access.
resource "aws_s3_bucket_public_access_block" "sentinel_logs" {
  bucket                  = aws_s3_bucket.sentinel_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

## S3 policy which allow cloud trail to write logs.
resource "aws_s3_bucket_policy" "sentinel_logs" {
  bucket = aws_s3_bucket.sentinel_logs.id

  policy = templatefile("${path.module}/iam_policies/allow-s3-cloudtrail.tpl.json", {
    account_id      = var.account_id
    organization_id = var.organization_id
    bucket_name     = aws_s3_bucket.sentinel_logs.id
  })
}

## s3 lifecycle rule to delete old files.
resource "aws_s3_bucket_lifecycle_configuration" "sentinel" {
  bucket = aws_s3_bucket.sentinel_logs.bucket

  rule {
    expiration {
      days = var.expiration_days
    }
    id = "clean"

    noncurrent_version_expiration {
      noncurrent_days = 1
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    status = "Enabled"
  }
}

## s3 notification to SQS to notify new logs have been stored.
resource "aws_s3_bucket_notification" "sentinel" {
  bucket = aws_s3_bucket.sentinel_logs.id

  queue {
    queue_arn = aws_sqs_queue.sentinel.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

# KMS key cloudtrail ueses to encrypt logs.
resource "aws_kms_key" "sentinel_logs" {
  description              = "Kms key to entrypt cloudtrail logs."
  customer_master_key_spec = "SYMMETRIC_DEFAULT"

  policy = templatefile("${path.module}/iam_policies/allow-kms-cloudtrail.tpl.json", {
    account_id = var.account_id
    trail_name = var.trail_name
    aws_region = var.aws_region
  })
}

resource "aws_kms_alias" "sentinel_logs" {
  name          = "alias/sentinel-logs-key"
  target_key_id = aws_kms_key.sentinel_logs.id
}

# Trail to collect all managements events.
resource "aws_cloudtrail" "sentinel" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.sentinel_logs.id
  include_global_service_events = true
  kms_key_id                    = aws_kms_key.sentinel_logs.arn
  is_organization_trail         = var.is_organization_trail
  is_multi_region_trail         = var.is_multi_region_trail

  event_selector {
    read_write_type                  = "All"
    include_management_events        = true
    exclude_management_event_sources = ["kms.amazonaws.com", ]
  }

  depends_on = [
    aws_s3_bucket_policy.sentinel_logs,
    aws_kms_key.sentinel_logs
  ]
}
