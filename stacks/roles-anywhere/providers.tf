terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Backend config supplied via -backend-config at `terraform init` time.
  # Example:
  #   terraform init \
  #     -backend-config="bucket=<state_bucket_name>" \
  #     -backend-config="key=stacks/roles-anywhere/terraform.tfstate" \
  #     -backend-config="region=us-east-1" \
  #     -backend-config="encrypt=true" \
  #     -backend-config="use_lockfile=true"
  backend "s3" {}
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
