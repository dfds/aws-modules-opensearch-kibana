variable "vpc" {}

data "aws_vpc" "open_search" {
  tags = {
    Name = var.vpc
  }
}

data "aws_subnet_ids" "open_search" {
  vpc_id = data.aws_vpc.open_search.id

  tags = {
    Tier = "private"
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "open_search" {
  name        = "${var.vpc}-opensearch-${var.opensearch_domain_name}"
  description = "Managed by Terraform"
  vpc_id      = data.aws_vpc.open_search.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      data.aws_vpc.open_search.cidr_block,
    ]
  }
}

resource "aws_iam_service_linked_role" "open_search" {
  aws_service_name = "opensearchservice.amazonaws.com"
}

resource "aws_opensearch_domain" "open_search" {
  domain_name    = var.opensearch_domain_name
  engine_version = "OpenSearch_1.0"

  cluster_config {
    instance_type          = "m4.large.search"
    zone_awareness_enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  node_to_node_encryption {
    enabled = true
  }


  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  vpc_options {
    subnet_ids = [
      data.aws_subnet_ids.open_search.ids[0],
      data.aws_subnet_ids.open_search.ids[1],
    ]

    security_group_ids = [aws_security_group.open_search.id]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.var.opensearch_domain_name}/*"
        }
    ]
}
CONFIG

  tags = {
    Domain = var.opensearch_domain_name
  }

  depends_on = [aws_iam_service_linked_role.open_search]
}

resource "aws_opensearch_domain_saml_options" "domain_saml_options" {
  domain_name = aws_opensearch_domain.domain.domain_name
  saml_options {
    enabled = true
    idp {
      entity_id        = "https://open_search.com"
      metadata_content = file("./saml-metadata.xml")
    }
  }
}