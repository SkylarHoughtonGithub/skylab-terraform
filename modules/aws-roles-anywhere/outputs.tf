output "role_arn" {
  value       = aws_iam_role.this.arn
  description = "ARN of the IAM role Roles Anywhere assumes."
}

output "role_name" {
  value       = aws_iam_role.this.name
  description = "Name of the role."
}

output "profile_arn" {
  value       = aws_rolesanywhere_profile.this.arn
  description = "ARN of the Roles Anywhere profile."
}
