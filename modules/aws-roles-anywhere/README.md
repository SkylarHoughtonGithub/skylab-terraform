# modules/roles-anywhere

Creates one Roles Anywhere "workload": an IAM role trusted by the Roles Anywhere service, plus a profile that binds it.

The trust anchor itself is a one-per-CA account resource and is created in `stacks/roles-anywhere` — this module takes its ARN as input and attaches a trust condition on `aws:SourceArn` so only credentials issued by that specific anchor can assume this role.

## Usage

```hcl
module "loki" {
  source = "../../modules/roles-anywhere"

  trust_anchor_arn = aws_rolesanywhere_trust_anchor.step_ca.arn
  role_name        = "skylab-loki"
  profile_name     = "skylab-loki"
  description      = "Loki in the hub cluster. Writes chunks and indexes to its S3 bucket."

  # Narrow once step-ca's cert naming convention is pinned.
  allowed_subject_cns = ["loki.observability.svc"]

  inline_policies = {
    loki-bucket = data.aws_iam_policy_document.loki_bucket.json
  }
}
```

## Trust shape

The generated role trusts `rolesanywhere.amazonaws.com` with `sts:AssumeRole + sts:TagSession + sts:SetSourceIdentity` and these conditions:

| Condition | Purpose |
| --- | --- |
| `ArnEquals` on `aws:SourceArn` | Only credentials from this exact trust anchor can assume the role. |
| `StringLike` on `aws:PrincipalTag/x509Subject/CN` (when `allowed_subject_cns` is set) | Workload cert must match one of the given CN patterns. |

Additional per-session narrowing can be done via `session_policy_json` on the profile.
