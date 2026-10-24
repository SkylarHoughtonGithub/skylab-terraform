# stacks/roles-anywhere

IAM Roles Anywhere trust anchor rooted at the Skylab offline root CA (see `scripts/skylab-ca.sh`), plus one profile+role per Skylab workload that needs short-lived AWS credentials without any static keys.

## Workloads currently covered

| Module | Workload | Policy (today) |
| --- | --- | --- |
| `loki` | Loki in the hub cluster | TODO: inline, scoped to the Loki bucket |
| `tempo` | Tempo in the hub cluster | TODO: inline, scoped to the Tempo bucket |
| `external_secrets` | ESO ClusterSecretStore for AWS SM | `SecretsManagerReadWrite` (TODO tighten) |
| `crossplane_aws` | Crossplane provider-aws | `AdministratorAccess` (TODO tighten) |

Bucket-scoped inline policies land once `stacks/storage/` provides bucket ARNs.

## Prerequisites

The Skylab root CA exists locally. Generate once with:

```sh
./scripts/skylab-ca.sh init-root
```

Private key stays under `$SKYLAB_CA_DIR` (default `~/.skylab-ca`, chmod 700). Back it up encrypted before registering a trust anchor against it. The `step_ca_root_pem` variable name is retained for backward compatibility with the stack's inputs.

## Deploy

```sh
cd stacks/roles-anywhere

terraform init \
  -backend-config="bucket=<state_bucket_name>" \
  -backend-config="key=stacks/roles-anywhere/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

terraform apply -var "step_ca_root_pem=$(../../scripts/skylab-ca.sh show-root)"
```

## Wiring into Kubernetes

The gitops side ships `charts/aws-signing-helper/` — a wave-0 CronJob that presents an mTLS cert to Roles Anywhere every 10 min and writes session credentials into `eso-aws-credentials` for ESO's AWS `ClusterSecretStore` to read. Leaf cert comes from `scripts/skylab-ca.sh issue` and lands in-cluster via `install-k8s` (see the gitops standup runbook). It takes three of this stack's outputs as values:

| Terraform output | gitops values key |
| --- | --- |
| `trust_anchor_arn` | `rolesAnywhere.trustAnchorArn` |
| `external_secrets_profile_arn` | `rolesAnywhere.profileArn` |
| `external_secrets_role_arn` | `rolesAnywhere.roleArn` |

The chart's `certificate.commonName` default (`aws-signing-helper`) must match the `allowed_subject_cns` entry on the external-secrets role.

Crossplane provider-aws reuses the pattern with the `crossplane_aws_*` outputs — wiring lives in `charts/crossplane-providers/` on the gitops side.

See **`skylab-gitops/docs/runbooks/live-aws-standup.md`** for the full cross-repo standup: Terraform apply → values seeding → ESO flip-on → Crossplane wave 1 → first XR provisioning.
