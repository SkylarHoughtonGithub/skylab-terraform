# stacks/identity

Account-wide identity:

- One GitHub Actions OIDC provider (singleton per AWS account).
- One IAM role per Skylab repo whose CI needs AWS access. First role is for `skylab-terraform` itself.

## Deploy

```sh
cd stacks/identity

terraform init \
  -backend-config="bucket=<state_bucket_name>" \
  -backend-config="key=stacks/identity/terraform.tfstate" \
  -backend-config="region=us-east-2" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

terraform apply
```

## Adding more CI roles

Instantiate `modules/github-oidc` with repo-scoped `allowed_subs` and the IAM policies that repo's workflows actually need. Keep patterns narrow (branch + pull_request, not `:*`).

## Not yet included

- IAM Roles Anywhere trust anchor + profiles (step-ca as the CA). Follow-up: `stacks/roles-anywhere/`.
- GCP Workload Identity Federation (CI pool + hub workload X.509 pool). Follow-up: `stacks/gcp-identity/`.
