# stacks/bootstrap

Creates the S3 bucket Terraform uses for remote state across every other stack. Uses native S3 lockfile locking (requires Terraform >= 1.11); no DynamoDB table.

## One-time run

```sh
cd stacks/bootstrap

# Create terraform.tfvars (not committed) with:
# state_bucket_name = "<something-globally-unique>"

terraform init
terraform apply
```

## After the bucket exists

Add a `backend "s3"` block to each other stack's `providers.tf`:

```hcl
backend "s3" {
  bucket       = "<state_bucket_name>"
  key          = "stacks/<stack-name>/terraform.tfstate"
  region       = "us-east-1"
  encrypt      = true
  use_lockfile = true   # native S3 locking (TF >= 1.11)
}
```

Then `terraform init` in each stack picks up remote state.

## Migrating the bootstrap stack itself

Optional. After the bucket is live, add a backend block to this stack too and run `terraform init -migrate-state` so bootstrap state lives in S3 like everything else. Keep a local copy of the state file as a safety net during migration.
