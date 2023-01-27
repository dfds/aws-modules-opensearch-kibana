variable "domain_name" {
  description = "Name of the domain"
  type        = string
}

variable "engine_version" {
  description = "Engine version for the Amazon OpenSearch Service domain"
  type        = string
  default     = "OpenSearch_1.0"
}

variable "instance_type" {
  description = "Instance type of data nodes in the cluster"
  type        = string
}

variable "availability_zones" {
  description = "Number of availability zones for the cluster. Valid values: 1, 2 or 3"
  type        = number
}

variable "ebs_enabled" {
  description = "Whether EBS volumes are attached to data nodes in the domain"
  type        = bool
  default     = false
}

variable "ebs_iops" {
  description = "Baseline input/output (I/O) performance of EBS volumes attached to data nodes. Applicable only for the GP3 and Provisioned IOPS EBS volume types"
  type        = number
  default     = 3000
}

variable "ebs_throughput" {
  description = "(Required if volume_type is set to gp3) Specifies the throughput (in MiB/s) of the EBS volumes attached to data nodes. Applicable only for the gp3 volume type. Valid values are between 125 and 1000"
  type        = number
  default     = 125
}

variable "ebs_volume_size" {
  description = " Size of EBS volumes attached to data nodes (in GiB)"
  type        = number
  default     = 10
}

variable "ebs_volume_type" {
  description = "Type of EBS volumes attached to data nodes"
  type        = string
  default     = "gp3"
}

variable "enable_encrypt_at_rest" {
  description = "Whether to enable encryption at rest"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = " KMS key ARN to encrypt the Elasticsearch domain with. If not specified then it defaults to using the aws/es service KMS key"
  type        = string
  default     = ""
}

variable "vpc_opensearch" {
  description = "Whether the OpenSearch cluster is deployed in a VPC"
  type        = bool
}

variable "security_group_ids" {
  description = "List of VPC Security Group IDs to be applied to the OpenSearch domain endpoints. If omitted, the default Security Group for the VPC will be used."
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of VPC Subnet IDs for the OpenSearch domain endpoints to be created in"
  type        = list(string)
  default     = []
}

variable "log_publishing_options" {
  description = "List of log_publishing_options configurations"
  type = list(object({
    cloudwatch_log_group_arn = string
    enabled                  = optional(bool)
    log_type                 = string
  }))
  default = []
}

variable "advanced_options" {
  description = "Key-value string pairs to specify advanced configuration options"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags"
  type        = map(any)
  default     = {}
}

variable "enable_saml_authentication" {
  description = "Whether to enable saml authentication for the OpenSearch domain"
  type        = bool
  default     = false
}

variable "entity_id" {
  description = "Unique Entity ID of the application in SAML Identity Provider"
  type        = string
  default     = ""
}

variable "metadata_content" {
  description = "Metadata of the SAML application in xml format"
  type        = string
  default     = ""
}

variable "create_security_group" {
  description = "Whether to create a security group for OpenSearch"
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "ID of the VPC where the OpenSearch will be created"
  type        = string
  default     = ""
}

variable "sg_ingress_rules" {
  description = "List of ingress rules for OpenSearch SG"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "create_service_role" {
  description = "Whether to create service linked role"
  type        = bool
  default     = true
}
