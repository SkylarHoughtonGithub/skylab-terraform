# scripts

Operator tools paired with the Terraform stacks here.

## `skylab-ca.sh`

Offline root CA for the Skylab trust layer. Replaces a running step-ca when all you need is a root cert for Roles Anywhere (AWS) and GCP Workload Identity Federation plus occasional leaf certs for workloads like `aws-signing-helper`.

Depends on the `step` CLI (`brew install step`) and `kubectl`.

```sh
# One-time. Writes root.{crt,key} under ~/.skylab-ca (chmod 700).
./scripts/skylab-ca.sh init-root

# Register the root as the Roles Anywhere trust anchor.
cd stacks/roles-anywhere
terraform apply -var "step_ca_root_pem=$(../../scripts/skylab-ca.sh show-root)"
cd -

# Per workload: issue a leaf, land it in the cluster as a tls Secret.
./scripts/skylab-ca.sh issue aws-signing-helper
./scripts/skylab-ca.sh install-k8s aws-signing-helper external-secrets
```

Leaf certs default to 30d. Rotate with `issue` + `install-k8s` again before expiry — the chart's CronJob picks up the new Secret on its next run.

Back up `$SKYLAB_CA_DIR` (encrypted) before issuing anything that lands in AWS. Losing the root key means re-registering the trust anchor and reissuing every leaf.
