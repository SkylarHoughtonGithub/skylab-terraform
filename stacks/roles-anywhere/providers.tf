terraform {
  backend "s3" {
    bucket = "skylab-platform-635314249418"
    key    = "terraform/roles-anywhere"
    region = "us-east-2"
  }
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      "skylab.io/stack" = "roles-anywhere"
      "skylab.io/owner" = "platform"
    }
  }
}
