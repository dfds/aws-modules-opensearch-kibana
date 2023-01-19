resource "aws_iam_service_linked_role" "this" {
  aws_service_name = "opensearchservice.amazonaws.com"
}

resource "aws_opensearch_domain" "this" {
  depends_on = [aws_iam_service_linked_role.this]

  domain_name    = var.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type          = var.instance_type
    zone_awareness_enabled = (var.availability_zones > 1) ? true : false

    dynamic "zone_awareness_config" {
      for_each = (var.availability_zones > 1) ? [var.availability_zones] : []
      content {
        availability_zone_count = zone_awareness_config.value
      }
    }
  }

  dynamic "ebs_options" {
    for_each = var.ebs_enabled ? [var.ebs_enabled] : []
    content {
      ebs_enabled = var.ebs_enabled
      volume_size = var.ebs_volume_size
      volume_type = var.ebs_volume_type
      throughput  = var.ebs_throughput
      iops        = var.ebs_iops
    }
  }

  encrypt_at_rest {
    enabled    = var.enable_encrypt_at_rest
    kms_key_id = var.kms_key_id
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  node_to_node_encryption {
    enabled = true
  }

  dynamic "vpc_options" {
    for_each = (length(var.subnet_ids) > 0) ? [true] : []
    content {
      security_group_ids = var.security_group_ids
      subnet_ids         = var.subnet_ids
    }
  }

  dynamic "log_publishing_options" {
    for_each = (length(var.log_publishing_options) > 0) ? [var.log_publishing_options] : []
    content {
      cloudwatch_log_group_arn = log_publishing_options.value["cloudwatch_log_group_arn"]
      enabled                  = log_publishing_options.value["enabled"]
      log_type                 = log_publishing_options.value["log_type"]
    }
  }

  advanced_options = var.advanced_options
  tags = merge(
    {
      Name = var.domain_name
    },
    var.additional_tags
  )
}

resource "aws_opensearch_domain_saml_options" "this" {
  count = var.enable_saml_authentication ? 1 : 0

  domain_name = aws_opensearch_domain.this.domain_name

  saml_options {
    enabled = var.enable_saml_authentication

    idp {
      entity_id        = var.entity_id
      metadata_content = var.metadata_content
    }
  }
}
