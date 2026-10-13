variable "region" {
  type        = string
  description = "AWS region for Roles Anywhere resources."
  default     = "us-east-1"
}

variable "step_ca_root_pem" {
  type        = string
  description = "PEM-encoded step-ca root certificate used as the Roles Anywhere trust anchor. Not committed; supply via tfvars, env var, or a Secrets Manager data source at apply time."
  sensitive   = true
}
