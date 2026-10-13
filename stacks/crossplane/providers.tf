terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Backend config supplied via -backend-config at `terraform init` time.
  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "skylab.io/stack" = "crossplane"
      "skylab.io/owner" = "platform"
    }
  }
}
