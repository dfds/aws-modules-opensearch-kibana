resource "aws_cognito_identity_pool" "elasticsearch" {
  provider = aws.cognito
  identity_pool_name               = "${var.environment}_kibana_elasticsearch"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = var.cognito_ip_client_id
    provider_name           = var.cognito_ip_provider_name
    server_side_token_check = var.cognito_ip_server_side_token_check
  }
}

resource "aws_iam_role" "authenticated" {
  provider = aws.cognito
  name               = "${local.constructed_name}-cognito-authenticated"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_auth.json}"
}

resource "aws_iam_role" "unauthenticated" {
  provider = aws.cognito
  name               = "${local.constructed_name}-cognito-unauthenticated"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_unauth.json}"
}

resource "aws_iam_role" "escognito" {
  provider = aws.cognito
  name = "${local.constructed_name}-elasticsearch-cognito"
  assume_role_policy = "${data.aws_iam_policy_document.escognito.json}"
}

data "aws_iam_policy_document" "escognito" {
  provider = aws.cognito
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "es.amazonaws.com",
      ]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "attach" {
  provider = aws.cognito
  role = "${aws_iam_role.escognito.id}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonESCognitoAccess"
}

data "aws_iam_policy_document" "assume_role_auth" {
  provider = aws.cognito
  statement {
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        "cognito-identity.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = ["${aws_cognito_identity_pool.elasticsearch.id}"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_unauth" {
  provider = aws.cognito
  statement {
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        "cognito-identity.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = ["${aws_cognito_identity_pool.elasticsearch.id}"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
  }
}

data "aws_iam_policy_document" "authenticated" {
  provider = aws.cognito
  statement {
    effect = "Allow"

    actions = [
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
      "cognito-identity:*",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "unauthenticated" {
  provider = aws.cognito
  statement {
    effect = "Allow"

    actions = [
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "authenticated" {
  provider = aws.cognito
  name   = "${local.constructed_name}-cognito-auth"
  policy = "${data.aws_iam_policy_document.authenticated.json}"
  role   = "${aws_iam_role.authenticated.id}"
}

resource "aws_iam_role_policy" "unauthenticated" {
  provider = aws.cognito
  name   = "${local.constructed_name}-cognito-unauth"
  policy = "${data.aws_iam_policy_document.unauthenticated.json}"
  role   = "${aws_iam_role.unauthenticated.id}"
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  provider = aws.cognito
  identity_pool_id = "${aws_cognito_identity_pool.elasticsearch.id}"

  roles = {
    "authenticated"   = "${aws_iam_role.authenticated.arn}"
    "unauthenticated" = "${aws_iam_role.unauthenticated.arn}"
  }
}