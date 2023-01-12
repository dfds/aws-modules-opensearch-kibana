output "kibana_endpoint" {
    value = aws_elasticsearch_domain.domain.kibana_endpoint
}

output "elasticsearch_endpoint" {
    value = aws_elasticsearch_domain.domain.endpoint
}

output "snapshot_bucket_id" {
    value = join("", aws_s3_bucket.snapshot.*.id)
}

output "snapshot_role_arn" {
  description = "ARN of the IAM role allowing access to the Elasticsearch snapshot bucket"
  value = join("", aws_iam_role.snapshot.*.arn)
}