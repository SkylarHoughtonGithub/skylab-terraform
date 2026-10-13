#  A GCP "workload" bound to a Workload Identity Federation pool: one
#  service account that external principals (from the given WIF pool) can
#  impersonate, plus the project-level roles the service account itself
#  carries.
#
#  The pool and its provider live in the stack (one per trust fabric —
#  one for GitHub OIDC, one for step-ca X.509). This module just takes
#  the pool name and the subject attribute value that is allowed to
#  impersonate the service account.

resource "google_service_account" "this" {
  project      = var.project_id
  account_id   = var.account_id
  display_name = var.display_name
  description  = var.description
}

#  Bind external WIF principals to impersonate this service account.
#  `member` is formatted by the caller — the shape depends on which
#  attribute the pool provider maps and what value you want to pin to.
#  Examples:
#    principal://iam.googleapis.com/projects/<n>/locations/global/workloadIdentityPools/<pool>/subject/<x509-cn>
#    principalSet://iam.googleapis.com/projects/<n>/locations/global/workloadIdentityPools/<pool>/attribute.repository/<org>/<repo>
resource "google_service_account_iam_member" "wif_impersonation" {
  for_each = toset(var.impersonation_members)

  service_account_id = google_service_account.this.name
  role               = "roles/iam.workloadIdentityUser"
  member             = each.value
}

#  Project-level roles granted to the service account itself. Scaffold
#  roles are intentionally broad; narrow once the workload's real API
#  surface is known.
resource "google_project_iam_member" "roles" {
  for_each = toset(var.project_roles)

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.this.email}"
}
