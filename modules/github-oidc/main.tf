# Reusable role bound to GitHub Actions via OIDC.
# The IAM OpenID Connect provider itself is a one-per-account global
# resource and is created in stacks/identity; this module takes its ARN.

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "GitHubOIDC"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # repo:org/repo:ref:refs/heads/<branch> or repo:org/repo:environment:<env> etc.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.allowed_subs
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  description        = var.description
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  max_session_duration = var.max_session_duration

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.managed_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies
  name     = each.key
  role     = aws_iam_role.this.id
  policy   = each.value
}
