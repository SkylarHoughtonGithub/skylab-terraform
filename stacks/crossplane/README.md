# stacks/crossplane

Scoped IAM policy for Crossplane provider-aws, used by the `crossplane_aws` role in `stacks/roles-anywhere`.

## Why a separate stack

The role itself lives in `stacks/roles-anywhere` because it needs the trust anchor ARN from that stack. The policy lives here so permissions can be reviewed and changed without touching the trust/profile wiring.

`stacks/roles-anywhere` looks up this policy by name via `aws_iam_policy` data source — so `var.policy_name` must match on both sides. Default is `skylab-crossplane-aws`.

## Apply order

1. `stacks/crossplane` (this stack) — creates the policy
2. `stacks/roles-anywhere` — looks up the policy and attaches it to the role

If you destroy, reverse the order.

## Scope

The policy allows:

| Service | Scope |
| --- | --- |
| EC2 networking | VPC/subnets/routes/SGs/NAT — all resources (no good ARN prefix for most of these) |
| EKS | full — all resources |
| IAM | `role/skylab-*`, `policy/skylab-*`, OIDC providers (for IRSA) |
| S3 | `bucket/skylab-*` only |
| RDS | full — all resources |
| KMS | read-only (describe + list) |

Deliberately **not** granted: KMS create/manage, non-Skylab IAM, raw EC2 (instances), route53 (Skylab uses external-dns), Secrets Manager (ESO has its own role).

Tighten further once compositions in `skylab-crossplane` are stabilized and we know exactly which actions are called.
