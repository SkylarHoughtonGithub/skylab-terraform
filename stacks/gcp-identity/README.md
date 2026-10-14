# stacks/gcp-identity

GCP mirror of the AWS identity story:

- One GCP project with the APIs Skylab needs.
- A **Workload Identity Federation pool for GitHub Actions**, so CI can `terraform apply` without any static GCP keys.
- A second **WIF pool trusting step-ca X.509 certs**, so hub-cluster workloads (Crossplane provider-gcp, External Secrets Operator, Argo CD) authenticate the same way they do on AWS via Roles Anywhere.
- Service accounts for those hub workloads with scaffold-time project roles.
- A delegated **Cloud DNS zone** for external-dns on the GKE spoke clusters.

Pair with `stacks/identity` (AWS GitHub OIDC + CI role) and `stacks/roles-anywhere` (AWS Roles Anywhere + step-ca). Same step-ca root; two clouds.

## Prerequisites

1. **A billing account** you can attach the project to. Grab the ID with `gcloud billing accounts list`.
2. **step-ca's root PEM**, same file used by `stacks/roles-anywhere`:
   ```sh
   kubectl -n step-ca get secret step-ca-certs -o jsonpath='{.data.root_ca\.crt}' | base64 -d > step_ca_root.pem
   ```

## Deploy

```sh
cd stacks/gcp-identity

terraform init \
  -backend-config="bucket=<state_bucket_name>" \
  -backend-config="key=stacks/gcp-identity/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"

terraform apply \
  -var "project_id=skylab-platform-<suffix>" \
  -var "billing_account=XXXXXX-XXXXXX-XXXXXX" \
  -var "dns_zone_dns_name=gcp.skylab.example.com." \
  -var "step_ca_root_pem=$(cat step_ca_root.pem)"
```

## Wiring into GitHub Actions

Workflows in `skylab-terraform` authenticate with:

```yaml
- uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: <output: github_wif_provider_name>
    service_account: <output: terraform_ci_service_account_email>
```

The provider's `attribute_condition` already restricts the pool to the `SkylarHoughtonGithub` org; the per-repo narrowing is on the service-account impersonation binding (`attribute.repository/<org>/skylab-terraform`).

## Wiring into the hub cluster (step-ca X.509 pool)

Each workload needs:

1. A `cert-manager` Certificate (via `StepClusterIssuer`) with the matching `commonName` pinned on the service account's `impersonation_members`:
   - `provider-gcp.crossplane-system.svc`
   - `external-secrets.external-secrets.svc`
   - `argocd-server.argocd.svc`, `argocd-application-controller.argocd.svc`
2. A credential config pointing at the pool provider and target service account. GCP's `gcloud auth login --cred-file=…` or the Workload Identity Federation client libraries both accept X.509 config files; see `plan.md` for the deferred wiring work in `skylab-gitops`.

## DNS

The managed zone has `dnssec_config { state = "on" }` (Trivy GCP-0059 flags off/transfer as HIGH). After the zone is created, grab the delegated nameservers from the `dns_zone_name_servers` output and set NS records at the parent registrar for `var.dns_zone_dns_name`.

## Scaffold-time roles (TODO tighten)

| Service account | Role granted | Target state |
| --- | --- | --- |
| `terraform-ci` | `roles/owner` | Narrow once the stacks' real API surface is pinned. |
| `skylab-crossplane-gcp` | `roles/editor` | Scoped custom role, like `stacks/crossplane/main.tf` on the AWS side. |
| `skylab-external-secrets-gcp` | `roles/secretmanager.secretAccessor` | Scope to specific secret paths once ESO's reads are known. |
| `skylab-argocd-gcp` | `roles/container.viewer` | Replace with per-spoke impersonation once GKE spokes exist. |
