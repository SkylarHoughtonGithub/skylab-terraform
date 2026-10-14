variable "role_name" {
  type        = string
  description = "Name of the IAM role that GitHub Actions assumes."
}

variable "description" {
  type        = string
  description = "Human description of what this role is for."
  default     = ""
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN of the GitHub Actions OIDC provider (created once per account in stacks/identity)."
}

variable "allowed_subs" {
  type        = list(string)
  description = "Allowed `sub` claim patterns, e.g. ['repo:org/repo:ref:refs/heads/main', 'repo:org/repo:pull_request']."
}

variable "managed_policy_arns" {
  type        = list(string)
  description = "ARNs of managed IAM policies to attach to the role."
  default     = []
}

variable "inline_policies" {
  type        = map(string)
  description = "Map of policy name to JSON for inline policies attached to the role."
  default     = {}
}

variable "max_session_duration" {
  type        = number
  description = "Max session duration in seconds. CI runs rarely need > 1h."
  default     = 3600
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the role."
  default     = {}
}
