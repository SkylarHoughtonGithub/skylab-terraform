variable "region" {
  type        = string
  description = "AWS region for the policy. Policies are global but the provider needs one."
  default     = "us-east-1"
}

variable "policy_name" {
  type        = string
  description = "Name of the managed IAM policy. Must match the name used in stacks/roles-anywhere so the data source lookup there finds it."
  default     = "skylab-crossplane-aws"
}
