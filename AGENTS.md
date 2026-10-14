# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

AWS and GCP foundations that must exist before any cluster can use either cloud: GitHub OIDC roles, IAM Roles Anywhere trust anchor, GCP Workload Identity Federation, object storage buckets for Loki/Tempo/TechDocs, and the qdevice stack. See `plan.md` for the full rework plan.

Legacy content under `terraform/development/` predates the rework and is migration source material.

## Layer

Terraform owns **static cloud foundations** that exist before any cluster. Crossplane (separate repo) owns **dynamic cloud resources** rendered from inside the cluster. The two never overlap.

## Workflow

- `main` is protected: branch and open a PR for every change (self-merge, 0 approvals).
- No `Co-Authored-By` trailers in commit messages.
- CI: `terraform fmt`, `validate`, tflint, Trivy/Checkov; plan comments on PR; apply on merge through the OIDC role.

## Target repo shape (post-rework)

```
modules/        # versioned, terraform-docs, tests
  github-oidc/
  roles-anywhere/
  object-storage/
  ecs-service/
stacks/
  bootstrap/    # state backend
  identity/     # GitHub OIDC, Roles Anywhere trust anchor + profiles
  storage/      # Loki/Tempo/TechDocs buckets
  crossplane/   # IAM for provider-aws
  qdevice/      # Dockerfile, ECR repo, ECS service
```

## Key decisions

**One step-ca root, two clouds.** AWS via IAM Roles Anywhere using step-ca as the trust anchor. GCP via Workload Identity Federation — step-ca X.509 certs for hub workloads, a separate OIDC pool for GitHub Actions. The same step-ca root is trusted by both clouds.

**No static credentials anywhere.** Done when `access_keys.sh` and every static AWS/GCP key is removed from Skylab.

## Cross-repo map

- `skylab-gitops` — Loki/Tempo (wave 5) consume the buckets and Roles Anywhere profiles from here
- `skylab-crossplane` — provider-aws IAM comes from the `crossplane/` stack
- `skylab-backstage` — TechDocs publishes to the TechDocs bucket
