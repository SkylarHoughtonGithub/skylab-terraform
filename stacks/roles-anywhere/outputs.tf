output "trust_anchor_arn" {
  value       = aws_rolesanywhere_trust_anchor.step_ca.arn
  description = "ARN of the step-ca-rooted Roles Anywhere trust anchor."
}

output "loki_profile_arn" {
  value       = module.loki.profile_arn
  description = "Profile ARN for Loki workload."
}

output "loki_role_arn" {
  value       = module.loki.role_arn
  description = "Role ARN for Loki workload."
}

output "tempo_profile_arn" {
  value       = module.tempo.profile_arn
  description = "Profile ARN for Tempo workload."
}

output "tempo_role_arn" {
  value       = module.tempo.role_arn
  description = "Role ARN for Tempo workload."
}

output "external_secrets_profile_arn" {
  value       = module.external_secrets.profile_arn
  description = "Profile ARN for External Secrets Operator."
}

output "external_secrets_role_arn" {
  value       = module.external_secrets.role_arn
  description = "Role ARN for External Secrets Operator."
}

output "crossplane_aws_profile_arn" {
  value       = module.crossplane_aws.profile_arn
  description = "Profile ARN for Crossplane provider-aws."
}

output "crossplane_aws_role_arn" {
  value       = module.crossplane_aws.role_arn
  description = "Role ARN for Crossplane provider-aws."
}
