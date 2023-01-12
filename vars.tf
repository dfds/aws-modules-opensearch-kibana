variable "aws_region" {
  description = "The AWS region to deploy to (e.g eu-west-1)"
  default = "eu-central-1"
}

variable "environment" {
    description = "The environment of the application. I.e Production, Test. Used to terrtag resources"
}

variable "application_name" {
    description = "The name of the application. Used to name and tag resources"
}

variable "elasticsearch_version" {
    description = "Version of elasticsearch to install"
    default = "8.6.0"
}

variable "instance_type" {
    description = "Type/size of the elasticsearch instances"
    default = "t2.small.search"
}

variable "instance_count" {
    description = "Number of instances to create"
    default = 2
}

variable "ebs_volume_size" {
    description = "Size in GB of EBS storage attached to nodes. Defaults to 20"
    default = 20
}

variable "automated_snapshot_start_hour" {
    description = "Hour of the day to create an automated snapshot"
}

variable "encrypt_at_rest_enabled" {
    description = "Encrypt data at rest. Defaults to true"
    default = true
}

variable "dedicated_master_enabled" {
    description = "Should dedicated master servers be enabled. Defaults to false"
    default = false
}

variable "dedicated_master_type" {
    description = "Instance type of the elasticsearch master"
    default = "t2.small.elasticsearch"
}

variable "dedicated_master_count" {
    description = "Number of master instances to create"
    default = 2
}

variable "zone_awareness_enabled" {
    description = "Indicates whether zone awareness is enabled"
    default = false
}

variable "availability_zone_count" {
    description = "Number of availability zones fomr the domain to use with zone_awareness_enabled. Defaults to 2"
    default = 2
}

variable "node_to_node_encryption" {
    description = "Whether to enable node-to-node encryption. Defaults to true"
    default = true
}

variable "vpc_id" {
    description = "The ID of the VPC in which to deploy elasticsearch"
}

variable "private_subnet_ids" {
    description = "List of private subnet ID's in which to deploy elasticsearch"
    type = list
}

variable "user_pool_id" {
    description = "The user pool ID of users allowed to sign in to Kibana"
}

variable "elasticsearch_domain_name" {
    description = "Domain name of the Elasticsearch user pool"
}

variable "aws_cognito_region" {
    description = "AWS Region in which Cognito user pool resides. Used to create the identity pool. Defaults to eu-west-1"
    default = "eu-west-1"
}

variable "snapshot_bucket_enabled" {
    description = "Create an S3 bucket that can be used for storing manual snapshots. Defaults to false"
    default = false
}

variable "bucket_identifier" {
    description = "Add a unique identifier to the bucketname to allow it to be globally unique"
    default = ""
}

variable "cognito_ip_client_id" {
    description = "The cognito pool client ID"
}

variable "cognito_ip_provider_name" {
    description = "The cognito pool provider name. E.g cognito-idp.us-east-1.amazonaws.com/us-east-1_Tv0493apJ"
}

variable "cognito_ip_server_side_token_check" {
    description = "Whether server-side token validation is enabled for the identity provider’s token or not. Defaults to true"
    default = true
}