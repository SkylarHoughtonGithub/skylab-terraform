# Skylab Platform Rework — skylab-terraform

Oct 12, 2026 · @Skylar

> One slice of a five-repo rework. See the **Cross-repo map** below for siblings.

## North star

Skylab becomes four public platform repos on GitHub plus a tenant repo in Gitea, built in a fixed order, with one owner per layer. It runs as a homelab hub managing spoke clusters on AWS and GCP. The old argo-\*, backstage-\* and shoutsky-images repos are archived once their contents have a new home. There is no live infrastructure to migrate, so every repo is built clean.

Humans and agents only ever write to Git; Argo CD is the single path into the clusters, and AWS foundations come from Terraform CI.

### Layer ownership

| Layer | Tool | Owns | Never touches |
| --- | --- | --- | --- |
| Delivery | Argo CD | Applying Git state to clusters; deciding which cluster gets what | Resources rendered by KubeVela |
| Infrastructure API | Crossplane | Cloud resources: EKS, networking, buckets, databases | Helm releases and app workloads |
| Application API | KubeVela | App components, traits, delivery workflow, the resources it renders | Cluster placement |
| Front door | Backstage | Catalog, templates, MCP actions for AI clients | Direct writes to clusters |
| Investigation | HolmesGPT | Read-only root-cause analysis of alerts | Any change to the system |
| Remediation | tack-ai | Proposing fixes as pull requests, behind policy and approval | Direct cluster changes |

### Cross-repo map

| Repo | Host | Replaces | Purpose |
| --- | --- | --- | --- |
| skylab-gitops | GitHub | skylab-argo-root, skylab-argo-bootstrap, skylab-argo-workloads | Everything Argo CD syncs: platform charts, cluster config, workloads |
| **skylab-terraform** (this repo) | GitHub | proxmox-qdevice from shoutsky-images | AWS and GCP foundations: OIDC, workload identity, buckets, IAM, qdevice |
| skylab-backstage | GitHub | skylab-backstage-catalog, Backstage image from shoutsky-images | Backstage app, image, chart, templates, plugins |
| skylab-crossplane | GitHub | crossplane-xrd folder in skylab-argo-bootstrap | Cloud-agnostic XRDs with AWS and GCP compositions, as an OCI package |
| platform/tenants | Gitea | skylab-backstage-configs | Scaffolder output: KubeVela Applications and infra requests |
| tack-ai | GitHub (existing) | n/a | Governed remediation agent; integration work only |

### Build order

1. **skylab-gitops**, including Gitea, KubeVela and the observability stack. Everything else plugs into it.
2. **skylab-terraform**, moved up because Loki, Tempo and TechDocs need buckets and Roles Anywhere before they can store anything.
3. **skylab-backstage**, including the Gitea pull-request action and MCP actions.
4. **skylab-crossplane**, with EKS and GKE behind one cluster API, handing new clusters to Argo CD.
5. **Archive the old repos** once each piece has moved.
6. **Golden paths**: KubeVela definitions and the templates that use them.
7. **AI layer**: model gateway, HolmesGPT, tack-ai remediation, kagent.
8. **Portfolio finish**: profile README, pins, ADRs.

---

## This repo

Terraform owns the AWS and GCP foundations that must exist before any cluster can use either cloud, and that Crossplane should not manage from inside the cluster. It also turns the qdevice bash script into a proper stack.

```
skylab-terraform/
├── modules/        # versioned, terraform-docs, tests
│   ├── github-oidc/
│   ├── roles-anywhere/
│   ├── object-storage/
│   └── ecs-service/
└── stacks/
    ├── bootstrap/  # state backend
    ├── identity/   # GitHub OIDC roles, Roles Anywhere trust anchor + profiles
    ├── storage/    # Loki, Tempo, TechDocs buckets with lifecycle rules
    ├── crossplane/ # IAM for provider-aws
    └── qdevice/    # Dockerfile, ECR repo, ECS service
```

### What it provides (AWS)

- **State backend:** S3 with native lockfile locking, bootstrapped once.
- **GitHub OIDC:** roles for each repo's CI, which removes every static AWS key, including the old images workflow and `access_keys.sh`.
- **IAM Roles Anywhere:** step-ca's root as the trust anchor, with profiles for Loki, Tempo, External Secrets Operator and Crossplane.
- **Object storage:** buckets for Loki, Tempo and TechDocs with retention lifecycle rules.
- **qdevice:** the Dockerfile moves here; the stack creates the ECR repo and ECS service, and CI builds and pushes the image with a pinned tag instead of `latest`.

### GCP

- **Project and APIs:** a Skylab project with only the needed APIs enabled (container, compute, storage, sql, secret manager).
- **Workload Identity Federation:** a GitHub OIDC pool for CI, plus a pool for hub workloads using step-ca X.509 certificates.
- **Service accounts:** least-privilege accounts for Crossplane provider-gcp, External Secrets Operator and Argo CD's GKE access.
- **DNS:** a delegated Cloud DNS zone for external-dns on GKE spokes.

### Identity shape (ADR driver)

- **AWS:** IAM Roles Anywhere with step-ca as the trust anchor.
- **GCP:** Workload Identity Federation. GitHub Actions federates through an OIDC pool for Terraform. Hub workloads (provider-gcp, External Secrets Operator, Argo CD) federate either through X.509 certificates from step-ca or through the cluster's service account tokens.
- **One root, two clouds:** a single step-ca root trusted by both clouds is a strong ADR and interview story.

Decision — **GCP identity for hub workloads:** X.509 federation vs. service account token federation. Lean: X.509, to mirror Roles Anywhere with the same step-ca.

### CI

- `terraform fmt`, `validate`, tflint and Trivy (or Checkov) on every PR.
- A plan posted as a PR comment; apply on merge through the OIDC role.
- terraform-docs keeps module READMEs current.

### Done when

- [ ] No static AWS credentials exist anywhere in Skylab
- [ ] Loki and Tempo authenticate through Roles Anywhere
- [ ] qdevice deploys from a merged PR

---

## Open decisions

| Decision | Options | Lean | Decide by |
| --- | --- | --- | --- |
| Object storage provider | S3, Cloudflare R2 | R2 if Loki query egress matters; S3 for one-provider simplicity | Start of this repo |

## Downstream consumers

- **skylab-gitops** wave 5 (Loki, Tempo) depends on the buckets and Roles Anywhere profiles created here.
- **skylab-crossplane** provider-aws IAM comes from the `crossplane/` stack.
- **skylab-backstage** TechDocs publishes to the TechDocs bucket.
