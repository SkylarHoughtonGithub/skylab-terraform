# modules/gcp-workload-identity

Creates one GCP service account plus the bindings needed to use it from a Workload Identity Federation pool: external principals get `roles/iam.workloadIdentityUser` to impersonate it, and the service account itself gets whatever project-level roles the workload needs.

The WIF pool and its provider are stack-level resources (one per trust fabric — a GitHub OIDC pool for CI, a step-ca X.509 pool for hub workloads). This module just wraps the per-workload shape.

## Usage

```hcl
module "crossplane_gcp" {
  source = "../../modules/gcp-workload-identity"

  project_id   = var.project_id
  account_id   = "skylab-crossplane-gcp"
  display_name = "Crossplane provider-gcp"
  description  = "Reconciles GKE, networks, buckets, Cloud SQL."

  impersonation_members = [
    "principal://iam.googleapis.com/${google_iam_workload_identity_pool.hub.name}/subject/provider-gcp.crossplane-system.svc",
  ]

  # TODO: tighten; `roles/editor` is scaffold-time.
  project_roles = [
    "roles/editor",
  ]
}
```

## Member format

The `impersonation_members` strings are formatted by the caller because they depend on which attribute the pool provider maps:

| Provider type | Attribute mapped | Member pattern |
| --- | --- | --- |
| GitHub OIDC | `attribute.repository = assertion.repository` | `principalSet://iam.googleapis.com/<pool>/attribute.repository/<org>/<repo>` |
| step-ca X.509 | `google.subject = assertion.subject.cn` | `principal://iam.googleapis.com/<pool>/subject/<cn>` |

See the stack's provider blocks for the actual attribute mapping.
