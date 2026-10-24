variable "region" {
  type        = string
  description = "AWS region for Roles Anywhere resources."
  default     = "us-east-2"
}

variable "step_ca_root_pem" {
  type        = string
  description = "PEM-encoded step-ca root certificate used as the Roles Anywhere trust anchor. Not committed; supply via tfvars, env var, or a Secrets Manager data source at apply time."
  sensitive   = true
}

variable "crossplane_policy_name" {
  type        = string
  description = "Name of the managed IAM policy created in stacks/crossplane. Must match stacks/crossplane var.policy_name."
  default     = "skylab-crossplane-aws"
}
