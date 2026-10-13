# modules/github-oidc

Creates an IAM role that GitHub Actions can assume via OpenID Connect. Pairs with the OIDC provider created once per account in `stacks/identity`.

## Usage

```hcl
module "my_ci_role" {
  source = "../../modules/github-oidc"

  role_name         = "skylab-terraform-ci"
  oidc_provider_arn = aws_iam_openid_connect_provider.github.arn
  description       = "CI role for skylab-terraform workflows"

  allowed_subs = [
    "repo:SkylarHoughtonGithub/skylab-terraform:ref:refs/heads/main",
    "repo:SkylarHoughtonGithub/skylab-terraform:pull_request",
  ]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
}
```

## Trust condition shape

Trust is enforced on the GitHub OIDC `sub` claim. Format examples:

| Pattern | Matches |
| --- | --- |
| `repo:org/repo:ref:refs/heads/main` | Runs on main branch |
| `repo:org/repo:pull_request` | PR workflow runs |
| `repo:org/repo:environment:prod` | Workflows targeting a named environment |
| `repo:org/repo:*` | Any workflow in the repo (least restrictive) |

Prefer narrower patterns in production.
