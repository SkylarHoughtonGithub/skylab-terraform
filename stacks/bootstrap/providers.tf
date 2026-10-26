terraform {
  backend "s3" {
    bucket = "skylab-platform-635314249418"
    key    = "terraform/bootstrap"
    region = "us-east-2"
  }

  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Bootstrap runs with LOCAL state the first time. After the state bucket
  # exists, migrate this stack's state to S3 by adding a `backend "s3"` block
  # below referencing the bucket, then `terraform init -migrate-state`.
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "skylab.io/stack" = "bootstrap"
      "skylab.io/owner" = "platform"
    }
  }
}
