output "service_account_email" {
  value       = google_service_account.this.email
  description = "Email address of the service account. Workloads impersonate this via WIF."
}

output "service_account_name" {
  value       = google_service_account.this.name
  description = "Fully-qualified resource name of the service account (projects/<n>/serviceAccounts/<email>)."
}

output "service_account_id" {
  value       = google_service_account.this.account_id
  description = "Short account ID (local-part of the email)."
}

output "service_account_unique_id" {
  value       = google_service_account.this.unique_id
  description = "Numeric unique ID. Stable across renames; useful for audit log correlation."
}
