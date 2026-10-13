variable "region" {
  type        = string
  description = "Default GCP region for regional resources in this stack."
  default     = "us-central1"
}

variable "project_id" {
  type        = string
  description = "Project ID for the Skylab GCP project. Must be globally unique and 6-30 lowercase chars/digits/hyphens."
}

variable "project_name" {
  type        = string
  description = "Human-friendly display name for the GCP project."
  default     = "Skylab Platform"
}

variable "billing_account" {
  type        = string
  description = "Billing account ID the project is attached to (e.g. 0123AB-456789-ABCDEF)."
}

variable "org_id" {
  type        = string
  description = "GCP organization ID the project lives under. Leave empty to create a standalone project (not under an org)."
  default     = ""
}

variable "folder_id" {
  type        = string
  description = "Optional GCP folder ID. Mutually exclusive with org_id — set at most one."
  default     = ""
}

variable "github_org" {
  type        = string
  description = "GitHub organization or user that owns the Skylab repos. Used to narrow the GitHub OIDC WIF provider attribute condition."
  default     = "SkylarHoughtonGithub"
}

variable "step_ca_root_pem" {
  type        = string
  description = "PEM-encoded step-ca root certificate used as the trust store for the hub workload X.509 WIF pool. Not committed; supply via tfvars, env var, or a secret-manager data source at apply time."
  sensitive   = true
}

variable "dns_zone_name" {
  type        = string
  description = "Resource name of the Cloud DNS managed zone (lowercase, hyphens; e.g. 'skylab-gcp')."
  default     = "skylab-gcp"
}

variable "dns_zone_dns_name" {
  type        = string
  description = "Fully-qualified DNS name delegated to this zone, with trailing dot (e.g. 'gcp.skylab.example.com.')."
}
