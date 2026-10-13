output "github_oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.github.arn
  description = "ARN of the GitHub Actions OIDC provider. Pass to modules/github-oidc for additional roles."
}

output "terraform_ci_role_arn" {
  value       = module.terraform_ci_role.role_arn
  description = "Role Actions in skylab-terraform assume. Reference in that repo's workflow with role-to-assume."
}
