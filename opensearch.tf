#####Comment to remove VPC

resource "aws_security_group" "es" {
  name        = "${local.constructed_name}-opensearch"
  description = "Managed by Terraform"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      data.aws_vpc.selected.cidr_block,
    ]
  }
}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

####### Comment to remove VPC

data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_iam_policy_document" "esdomain" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.opensearch_domain_name}/*"
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_iam_role.authenticated.arn
      ]
    }

    actions = ["es:ESHttp*"]
  }
}

resource "aws_opensearch_domain" "domain" {
  domain_name = var.opensearch_domain_name
  opensearch_version = var.opensearch_version

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.example.arn
    log_type                 = "AUDIT_LOGS"
    enabled                  = true  
  }

  domain_endpoint_options {
     enforce_https = true
     tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
   }

  cluster_config {
    instance_type = var.instance_type
    instance_count = var.instance_count
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_type = var.dedicated_master_type
    dedicated_master_count = var.dedicated_master_count
    zone_awareness_enabled = var.zone_awareness_enabled

    zone_awareness_config {
      availability_zone_count = var.availability_zone_count
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size
  }

  encrypt_at_rest {
    enabled = var.encrypt_at_rest_enabled
  }

  cognito_options {
    enabled = true
    user_pool_id = var.user_pool_id
    identity_pool_id = aws_cognito_identity_pool.opensearch.id
    role_arn = aws_iam_role.escognito.arn
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption
  }

##### Comment to remove VPC

  vpc_options {
    subnet_ids = var.private_subnet_ids
    security_group_ids = [
      aws_security_group.es.id
    ]
  }

  log_publishing_options {
    log_type = "INDEX_SLOW_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.index.arn
    enabled = true
  }

  log_publishing_options {
    log_type = "SEARCH_SLOW_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.search.arn
    enabled = true
  }

  log_publishing_options {
    log_type = "ES_APPLICATION_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.error.arn
    enabled = true
  }

  access_policies = data.aws_iam_policy_document.esdomain.json
  
  tags = local.common_tags

  depends_on = [
    "aws_iam_service_linked_role.es",
  ]
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

## S3 snapshot bucket
resource "aws_s3_bucket" "snapshot" {
  count = var.snapshot_bucket_enabled ? 1 : 0
  bucket = "${local.constructed_name}-opensearch-snapshots${var.bucket_identifier}"
  acl = "private"
  tags = local.common_tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "snapshot_bucket" {
  count = var.snapshot_bucket_enabled ? 1 : 0
  bucket = aws_s3_bucket.snapshot.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "snapshot_policy" {
  count = var.snapshot_bucket_enabled ? 1 : 0

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "iam:PassRole",
    ]

    resources = [
      aws_s3_bucket.snapshot[0].arn,
      "${aws_s3_bucket.snapshot[0].arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "snapshot" {
  count              = var.snapshot_bucket_enabled ? 1 : 0
  name               = "${local.constructed_name}-snapshot"
  description        = "Role used for opensearch snapshots"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}

resource "aws_iam_policy" "snapshot_policy" {
  count       = var.snapshot_bucket_enabled ? 1 : 0
  name        = "${local.constructed_name}-snapshot"
  description = "Policy allowing the opensearch domain access to the snapshots S3 bucket"
  policy      = data.aws_iam_policy_document.snapshot_policy[0].json
}

resource "aws_iam_role_policy_attachment" "snapshot_policy_attachment" {
  count      = var.snapshot_bucket_enabled ? 1 : 0
  role       = aws_iam_role.snapshot[0].id
  policy_arn = aws_iam_policy.snapshot_policy[0].arn
}