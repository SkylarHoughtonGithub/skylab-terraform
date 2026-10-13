# stacks/roles-anywhere

IAM Roles Anywhere trust anchor rooted at step-ca, plus one profile+role per Skylab workload that needs short-lived AWS credentials without any static keys.

## Workloads currently covered

| Module | Workload | Policy (today) |
| --- | --- | --- |
| `loki` | Loki in the hub cluster | TODO: inline, scoped to the Loki bucket |
| `tempo` | Tempo in the hub cluster | TODO: inline, scoped to the Tempo bucket |
| `external_secrets` | ESO ClusterSecretStore for AWS SM | `SecretsManagerReadWrite` (TODO tighten) |
| `crossplane_aws` | Crossplane provider-aws | `AdministratorAccess` (TODO tighten) |

Bucket-scoped inline policies land once `stacks/storage/` provides bucket ARNs.

## Prerequisites

1. **step-ca is running** in the hub cluster (wave 0 in `skylab-gitops`).
2. **step-ca's root PEM** is retrievable — grab it with:
   ```sh
   kubectl -n step-ca get secret step-ca-certs -o jsonpath='{.data.root_ca\.crt}' | base64 -d
   ```
   Save as `step_ca_root.pem` (do not commit).

## Deploy

```sh
cd stacks/roles-anywhere

terraform init \
  -backend-config="bucket=<state_bucket_name>" \
  -backend-config="key=stacks/roles-anywhere/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

terraform apply -var "step_ca_root_pem=$(cat step_ca_root.pem)"
```

## Wiring into Kubernetes

Each workload needs:

1. A cert-manager Certificate (via `StepClusterIssuer`) whose `commonName` matches the role's `allowed_subject_cns`.
2. The `aws_signing_helper credential-process` sidecar (or the aws-sigv4-signer initContainer) referencing the profile + role ARN output from this stack.

See `plan.md` for the deferred wiring work in `skylab-gitops` once step-ca is live.
