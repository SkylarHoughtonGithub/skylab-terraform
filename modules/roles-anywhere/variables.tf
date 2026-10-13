variable "trust_anchor_arn" {
  type        = string
  description = "ARN of the Roles Anywhere trust anchor rooted at step-ca."
}

variable "role_name" {
  type        = string
  description = "Name of the IAM role Roles Anywhere assumes for this workload."
}

variable "profile_name" {
  type        = string
  description = "Name of the Roles Anywhere profile that binds the role."
}

variable "description" {
  type        = string
  description = "Human description of what this role is for."
  default     = ""
}

variable "allowed_subject_cns" {
  type        = list(string)
  description = "Optional x.509 subject CN patterns (StringLike). Empty = any subject under the trust anchor."
  default     = []
}

variable "managed_policy_arns" {
  type        = list(string)
  description = "ARNs of managed policies to attach to the role."
  default     = []
}

variable "inline_policies" {
  type        = map(string)
  description = "Map of policy name to JSON for inline policies attached to the role."
  default     = {}
}

variable "session_policy_json" {
  type        = string
  description = "Optional JSON session policy attached to the profile. Narrows credentials further than the role itself."
  default     = ""
}

variable "max_session_duration" {
  type        = number
  description = "Max session duration in seconds (900–43200)."
  default     = 3600
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the role and the profile."
  default     = {}
}
