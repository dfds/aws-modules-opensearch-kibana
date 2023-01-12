# Opensearch Logs

resource "aws_cloudwatch_log_group" "search" {
  name = "/aws/aes/domains/${local.constructed_name}/search"
  retention_in_days = 60
}

resource "aws_cloudwatch_log_resource_policy" "search" {
  policy_name = "${local.constructed_name}-search"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

resource "aws_cloudwatch_log_group" "index" {
  name = "/aws/aes/domains/${local.constructed_name}/index"
  retention_in_days = 60
}

resource "aws_cloudwatch_log_resource_policy" "index" {
  policy_name = "${local.constructed_name}-index"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

resource "aws_cloudwatch_log_group" "error" {
  name = "/aws/aes/domains/${local.constructed_name}/error"
  retention_in_days = 60
}

resource "aws_cloudwatch_log_resource_policy" "error" {
  policy_name = "${local.constructed_name}-error"

  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

