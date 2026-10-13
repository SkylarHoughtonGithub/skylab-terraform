# GCP identity foundations:
#   1. One GCP project holding every Skylab GCP resource.
#   2. The APIs the hub cluster + follow-on stacks need.
#   3. A Workload Identity Federation pool for GitHub Actions (CI).
#   4. A second WIF pool for hub workloads, trusted via step-ca X.509 certs.
#      Mirror of the AWS Roles Anywhere trust fabric: one step-ca root, two clouds.
#   5. Service accounts for the hub workloads, impersonated via that X.509 pool.
#   6. A delegated Cloud DNS zone for external-dns on GKE spokes.
#
# The step-ca root PEM is supplied via `step_ca_root_pem` (variable), not
# committed. See stacks/roles-anywhere for the matching AWS side.

# -----------------------------------------------------------------------------
# 1. Project
# -----------------------------------------------------------------------------

resource "google_project" "this" {
  name       = var.project_name
  project_id = var.project_id

  billing_account = var.billing_account

  # Set at most one of org_id / folder_id; leaving both empty creates a
  # standalone project (fine for a homelab, flagged by some policies in
  # a corporate org).
  org_id    = var.org_id != "" ? var.org_id : null
  folder_id = var.folder_id != "" ? var.folder_id : null

  # The default compute service account is auto-created with roles/editor;
  # the hub never uses it. Leave `auto_create_network = false` so no
  # default VPC is created either — Crossplane will manage networking.
  auto_create_network = false

  labels = {
    "skylab-io-stack" = "gcp-identity"
    "skylab-io-owner" = "platform"
  }
}

# -----------------------------------------------------------------------------
# 2. APIs
# -----------------------------------------------------------------------------

locals {
  enabled_apis = [
    "container.googleapis.com",
    "compute.googleapis.com",
    "storage.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.enabled_apis)

  project = google_project.this.project_id
  service = each.value

  # Keep APIs enabled on destroy; disabling container.googleapis.com on
  # a project that still has clusters would break them.
  disable_on_destroy         = false
  disable_dependent_services = false
}

# -----------------------------------------------------------------------------
# 3. WIF pool for GitHub Actions (CI)
# -----------------------------------------------------------------------------

resource "google_iam_workload_identity_pool" "github" {
  project                   = google_project.this.project_id
  workload_identity_pool_id = "skylab-github-actions"
  display_name              = "GitHub Actions"
  description               = "WIF pool for GitHub Actions workflows in the Skylab repos."

  depends_on = [google_project_service.apis]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = google_project.this.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub OIDC"
  description                        = "GitHub Actions OIDC issuer."

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
    # allowed_audiences omitted → GCP accepts the default audience
    # (the full provider resource name), which the official
    # google-github-actions/auth action supplies automatically.
  }

  # Map GitHub's standard OIDC claims onto principalSet attributes we can
  # bind on. `google.subject` must be unique per federated identity.
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Only accept tokens from repos owned by the Skylab GitHub org.
  # Per-repo narrowing happens on the service account impersonation
  # binding (`attribute.repository = org/repo`).
  attribute_condition = "assertion.repository_owner == \"${var.github_org}\""
}

# Terraform CI service account. GitHub Actions in skylab-terraform
# federates into this via the GitHub pool.
resource "google_service_account" "terraform_ci" {
  project      = google_project.this.project_id
  account_id   = "terraform-ci"
  display_name = "Terraform CI (GitHub Actions)"
  description  = "Impersonated by GitHub Actions in skylab-terraform via WIF."
}

resource "google_service_account_iam_member" "terraform_ci_wif" {
  service_account_id = google_service_account.terraform_ci.name
  role               = "roles/iam.workloadIdentityUser"
  # repo:org/repo:* — any workflow in skylab-terraform. CI role is only
  # as broad as the project roles below; narrow sub-claim if needed.
  member = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_org}/skylab-terraform"
}

# TODO: tighten once we know which services the stacks actually touch.
# `roles/owner` is a scaffold-time convenience, same shape as the AWS
# AdministratorAccess attachment in stacks/identity.
resource "google_project_iam_member" "terraform_ci_owner" {
  project = google_project.this.project_id
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.terraform_ci.email}"
}

# -----------------------------------------------------------------------------
# 4. WIF pool for hub workloads via step-ca X.509
# -----------------------------------------------------------------------------

resource "google_iam_workload_identity_pool" "hub" {
  project                   = google_project.this.project_id
  workload_identity_pool_id = "skylab-hub-x509"
  display_name              = "Skylab hub workloads"
  description               = "WIF pool for in-cluster hub workloads authenticating with step-ca X.509 certs."

  depends_on = [google_project_service.apis]
}

resource "google_iam_workload_identity_pool_provider" "hub_x509" {
  project                            = google_project.this.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.hub.workload_identity_pool_id
  workload_identity_pool_provider_id = "step-ca"
  display_name                       = "step-ca X.509"
  description                        = "Trusts workload certs issued by Skylab's step-ca root."

  x509 {
    trust_store {
      trust_anchors {
        pem_certificate = var.step_ca_root_pem
      }
    }
  }

  # The subject CN of the workload cert is bound to `google.subject`; the
  # impersonation binding on each service account pins the exact CN
  # allowed (mirror of the Roles Anywhere `allowed_subject_cns` idea).
  attribute_mapping = {
    "google.subject" = "assertion.subject.cn"
  }
}

# -----------------------------------------------------------------------------
# 5. Hub workload service accounts (via module)
# -----------------------------------------------------------------------------

# Crossplane provider-gcp — manages GKE, VPC, GCS, Cloud SQL from inside the cluster.
module "crossplane_gcp" {
  source = "../../modules/gcp-workload-identity"

  project_id   = google_project.this.project_id
  account_id   = "skylab-crossplane-gcp"
  display_name = "Crossplane provider-gcp"
  description  = "Reconciles GKE, VPC, Cloud SQL, GCS for Skylab."

  impersonation_members = [
    "principal://iam.googleapis.com/${google_iam_workload_identity_pool.hub.name}/subject/provider-gcp.crossplane-system.svc",
  ]

  # TODO: tighten; mirrors the Crossplane-AWS AdministratorAccess scaffold
  # on the AWS side. Should eventually be a scoped custom role similar to
  # stacks/crossplane/main.tf.
  project_roles = [
    "roles/editor",
  ]
}

# External Secrets Operator — reads from GCP Secret Manager.
module "external_secrets_gcp" {
  source = "../../modules/gcp-workload-identity"

  project_id   = google_project.this.project_id
  account_id   = "skylab-external-secrets-gcp"
  display_name = "External Secrets Operator (GCP)"
  description  = "ESO ClusterSecretStore for GCP Secret Manager."

  impersonation_members = [
    "principal://iam.googleapis.com/${google_iam_workload_identity_pool.hub.name}/subject/external-secrets.external-secrets.svc",
  ]

  # TODO: tighten to specific secret paths once we know what ESO reads.
  project_roles = [
    "roles/secretmanager.secretAccessor",
  ]
}

# Argo CD — reads GKE cluster credentials to sync spokes.
module "argocd_gcp" {
  source = "../../modules/gcp-workload-identity"

  project_id   = google_project.this.project_id
  account_id   = "skylab-argocd-gcp"
  display_name = "Argo CD (GKE access)"
  description  = "Argo CD's path to GKE spoke clusters via WIF + impersonation."

  impersonation_members = [
    "principal://iam.googleapis.com/${google_iam_workload_identity_pool.hub.name}/subject/argocd-server.argocd.svc",
    "principal://iam.googleapis.com/${google_iam_workload_identity_pool.hub.name}/subject/argocd-application-controller.argocd.svc",
  ]

  # TODO: swap for the GKE workload identity dance (impersonation into
  # per-cluster SAs) once the spoke clusters land.
  project_roles = [
    "roles/container.viewer",
  ]
}

# -----------------------------------------------------------------------------
# 6. Cloud DNS zone (delegated subdomain for external-dns on GKE spokes)
# -----------------------------------------------------------------------------

resource "google_dns_managed_zone" "spokes" {
  project     = google_project.this.project_id
  name        = var.dns_zone_name
  dns_name    = var.dns_zone_dns_name
  description = "Delegated zone for external-dns on GKE spokes."

  # DNSSEC on — Trivy GCP-0059 flags zones without it as HIGH.
  dnssec_config {
    state = "on"
  }

  depends_on = [google_project_service.apis]
}
