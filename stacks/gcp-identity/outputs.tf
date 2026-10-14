output "project_id" {
  value       = google_project.this.project_id
  description = "ID of the Skylab GCP project."
}

output "project_number" {
  value       = google_project.this.number
  description = "Numeric project number. Needed for some IAM principal strings."
}

# -----------------------------------------------------------------------------
# WIF pools / providers
# -----------------------------------------------------------------------------

output "github_wif_pool_name" {
  value       = google_iam_workload_identity_pool.github.name
  description = "Fully-qualified resource name of the GitHub Actions WIF pool."
}

output "github_wif_provider_name" {
  value       = google_iam_workload_identity_pool_provider.github.name
  description = "Fully-qualified resource name of the GitHub OIDC provider. Pass to google-github-actions/auth."
}

output "hub_wif_pool_name" {
  value       = google_iam_workload_identity_pool.hub.name
  description = "Fully-qualified resource name of the hub-workloads (step-ca X.509) WIF pool."
}

output "hub_wif_provider_name" {
  value       = google_iam_workload_identity_pool_provider.hub_x509.name
  description = "Fully-qualified resource name of the step-ca X.509 provider."
}

# -----------------------------------------------------------------------------
# Service accounts
# -----------------------------------------------------------------------------

output "terraform_ci_service_account_email" {
  value       = google_service_account.terraform_ci.email
  description = "Service account GitHub Actions in skylab-terraform impersonates."
}

output "crossplane_gcp_service_account_email" {
  value       = module.crossplane_gcp.service_account_email
  description = "Service account for Crossplane provider-gcp."
}

output "external_secrets_gcp_service_account_email" {
  value       = module.external_secrets_gcp.service_account_email
  description = "Service account for External Secrets Operator (GCP Secret Manager)."
}

output "argocd_gcp_service_account_email" {
  value       = module.argocd_gcp.service_account_email
  description = "Service account for Argo CD's GKE access."
}

# -----------------------------------------------------------------------------
# DNS
# -----------------------------------------------------------------------------

output "dns_zone_name" {
  value       = google_dns_managed_zone.spokes.name
  description = "Resource name of the Cloud DNS managed zone."
}

output "dns_zone_name_servers" {
  value       = google_dns_managed_zone.spokes.name_servers
  description = "NS records to configure at the parent registrar to delegate this subdomain."
}
