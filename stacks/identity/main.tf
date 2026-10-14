# Account-wide identity resources. The GitHub Actions OIDC provider is a
# singleton per AWS account; CI roles for each Skylab repo use the
# modules/github-oidc helper and attach to this provider.

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # AWS maintains thumbprints for well-known IdPs automatically; this list
  # is a safety net kept in sync with GitHub's docs.
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd",
  ]
}

# CI role for skylab-terraform itself. Lets Actions in this repo plan and
# apply the Terraform stacks here.
module "terraform_ci_role" {
  source = "../../modules/aws-github-oidc"

  role_name         = "skylab-terraform-ci"
  description       = "GitHub Actions CI role for the skylab-terraform repo."
  oidc_provider_arn = aws_iam_openid_connect_provider.github.arn

  allowed_subs = [
    "repo:${var.github_org}/skylab-terraform:ref:refs/heads/main",
    "repo:${var.github_org}/skylab-terraform:pull_request",
  ]

  # TODO: tighten once we know which services the stacks actually touch.
  # AdministratorAccess is a scaffold-time convenience.
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
}
