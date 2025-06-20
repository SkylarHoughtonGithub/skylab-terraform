variable "key_name" { default = "skylab" }

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpc_name" {
  description = "Name of the VPC to use"
  type        = string
  default     = "skylab"
}

variable "subnet_selection" {
  description = "How to select subnet: 'first', 'public', 'private', or specific subnet ID"
  type        = string
  default     = "private"
}