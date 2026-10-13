variable "region" {
  type        = string
  description = "AWS region for identity resources."
  default     = "us-east-1"
}

variable "github_org" {
  type        = string
  description = "GitHub organization or user that owns the Skylab repos."
  default     = "SkylarHoughtonGithub"
}
