provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 4.0"
}

provider "aws" {
  region = "${var.aws_cognito_region}"
  version = "~> 4.0"
  alias = "cognito"
}

terraform {
  backend "s3" {
    # This configuration will be filled in by Terragrunt
  }
}

locals {
  common_tags = {
    Application = "${var.application_name}"
    Environment = "${var.environment}"
  }
  constructed_name = "${var.environment}-${var.application_name}"
}
