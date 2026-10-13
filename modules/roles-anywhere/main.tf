# A Roles Anywhere "workload" — one IAM role plus a profile that binds it,
# all under a shared trust anchor (passed in from the stack).

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid = "RolesAnywhere"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
      "sts:SetSourceIdentity",
    ]

    principals {
      type        = "Service"
      identifiers = ["rolesanywhere.amazonaws.com"]
    }

    # Pin assumption to this exact trust anchor; prevents another CA under
    # the same AWS account from assuming this role.
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.trust_anchor_arn]
    }

    # Optionally restrict to specific x.509 subject CNs. Set via var;
    # tightens trust once step-ca's workload cert naming convention is pinned.
    dynamic "condition" {
      for_each = length(var.allowed_subject_cns) > 0 ? [1] : []
      content {
        test     = "StringLike"
        variable = "aws:PrincipalTag/x509Subject/CN"
        values   = var.allowed_subject_cns
      }
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = var.role_name
  description          = var.description
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
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

resource "aws_rolesanywhere_profile" "this" {
  name      = var.profile_name
  role_arns = [aws_iam_role.this.arn]
  enabled   = true

  # Session policies restrict what the issued credentials can do, in
  # addition to what the role permits — useful for narrowing per workload.
  session_policy = length(var.session_policy_json) > 0 ? var.session_policy_json : null

  tags = var.tags
}
