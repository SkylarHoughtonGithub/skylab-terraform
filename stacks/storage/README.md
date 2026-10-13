# stacks/storage

Object storage for the three cluster-side consumers that live in `skylab-gitops` and `skylab-backstage`:

- **Loki** — log chunks. 90-day transition to `GLACIER_IR`, noncurrent versions expired after 90 days, incomplete multipart uploads aborted after 7 days.
- **Tempo** — trace blocks. Same lifecycle as Loki.
- **TechDocs** — rendered Backstage docs. No lifecycle; docs persist indefinitely.

All three buckets share one customer-managed KMS CMK (`alias/skylab-storage`). SSE-KMS, versioning, and the full `aws_s3_bucket_public_access_block` are set by `modules/object-storage`.

## Deploy

```sh
cd stacks/storage

terraform init \
  -backend-config="bucket=<state_bucket_name>" \
  -backend-config="key=stacks/storage/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

# Create terraform.tfvars (not committed) with:
# bucket_name_prefix = "skylab-<something-globally-unique>"

terraform apply
```

Final bucket names become `<bucket_name_prefix>-loki`, `<bucket_name_prefix>-tempo`, `<bucket_name_prefix>-techdocs`.

## Consumer wiring (not here)

IAM policies that let the Loki, Tempo, and Backstage workload roles reach these buckets live elsewhere (future `stacks/roles-anywhere/` profiles for the in-cluster workloads; `stacks/identity/` for the Backstage CI role publisher). This stack only exposes the bucket ARNs and the CMK ARN via outputs.
