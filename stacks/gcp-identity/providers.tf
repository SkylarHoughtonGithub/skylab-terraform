terraform {
  required_version = ">= 1.11"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Backend config supplied via -backend-config at `terraform init` time so
  # bucket name and region can live outside the repo. The state bucket is
  # the same one bootstrap/ creates for every stack (AWS S3); GCP identity
  # resources are a separate state file, not a separate backend provider.
  # Example:
  #   terraform init \
  #     -backend-config="bucket=<state_bucket_name>" \
  #     -backend-config="key=stacks/gcp-identity/terraform.tfstate" \
  #     -backend-config="region=us-east-1" \
  #     -backend-config="encrypt=true" \
  #     -backend-config="use_lockfile=true"
  backend "s3" {}
}

provider "google" {
  # Project set at the resource level via var.project_id — this stack
  # creates the project, so a provider-level default would be a chicken-
  # and-egg trap on first apply.
  region = var.region
}
