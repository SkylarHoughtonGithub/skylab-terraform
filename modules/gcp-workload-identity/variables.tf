variable "project_id" {
  type        = string
  description = "GCP project the service account lives in."
}

variable "account_id" {
  type        = string
  description = "Service account ID (the local-part of its email). 6-30 chars, lowercase, digits, hyphens."
}

variable "display_name" {
  type        = string
  description = "Human-friendly display name for the service account."
  default     = ""
}

variable "description" {
  type        = string
  description = "Human description of what this service account is for."
  default     = ""
}

variable "impersonation_members" {
  type        = list(string)
  description = "WIF principal/principalSet members allowed to impersonate the service account (roles/iam.workloadIdentityUser). Caller formats these to match the pool provider's attribute mapping."
  default     = []
}

variable "project_roles" {
  type        = list(string)
  description = "Project-level IAM roles granted to the service account. Scaffold-time values are typically broad; TODO tighten per workload."
  default     = []
}
