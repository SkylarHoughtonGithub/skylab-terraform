# skylab-terraform

AWS and GCP foundations for the Skylab platform: state backend, GitHub OIDC roles, Roles Anywhere, GCP Workload Identity Federation, object storage for Loki/Tempo/TechDocs, and the qdevice stack. See [`plan.md`](./plan.md) for the full rework plan.

Legacy content under `terraform/development/` predates the rework and is migration source material.

## Layout

```
modules/   # reusable, versioned modules
  github-oidc/
stacks/    # one-off deployable stacks
  bootstrap/    # S3 state backend (one-time)
  identity/     # GitHub OIDC provider + CI roles
```
