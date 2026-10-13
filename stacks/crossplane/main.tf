# Scoped IAM policy for Crossplane provider-aws.
#
# The role itself lives in stacks/roles-anywhere (attached to the step-ca
# Roles Anywhere trust anchor). That stack reads this policy by name via
# an aws_iam_policy data source, so we must keep var.policy_name in sync
# across both stacks. The default (`skylab-crossplane-aws`) matches the
# default on the other side; override in both if you rename.

data "aws_iam_policy_document" "crossplane_aws" {
  # Networking — VPCs, subnets, NAT gateways, route tables, security groups.
  statement {
    sid    = "Networking"
    effect = "Allow"
    actions = [
      "ec2:*Vpc*",
      "ec2:*Subnet*",
      "ec2:*Route*",
      "ec2:*InternetGateway*",
      "ec2:*NatGateway*",
      "ec2:*ElasticIp*",
      "ec2:AllocateAddress",
      "ec2:ReleaseAddress",
      "ec2:*SecurityGroup*",
      "ec2:*NetworkAcl*",
      "ec2:*Tags*",
      "ec2:Describe*",
    ]
    resources = ["*"]
  }

  # EKS — control planes, access entries, node groups.
  statement {
    sid    = "EKS"
    effect = "Allow"
    actions = [
      "eks:*",
    ]
    resources = ["*"]
  }

  # IAM — roles, policies, OIDC providers used by EKS access entries and
  # IRSA. Restricted to the Skylab prefix so Crossplane cannot touch
  # roles outside its scope.
  statement {
    sid    = "IAMForEKS"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:ListRoles",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:GetRolePolicy",
      "iam:ListRolePolicies",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicies",
      "iam:ListPolicyVersions",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviders",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
      "iam:PassRole",
    ]
    resources = [
      "arn:aws:iam::*:role/skylab-*",
      "arn:aws:iam::*:policy/skylab-*",
      "arn:aws:iam::*:oidc-provider/*",
    ]
  }

  # S3 — buckets. Skylab-prefixed only.
  statement {
    sid    = "S3Buckets"
    effect = "Allow"
    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:GetBucket*",
      "s3:ListBucket*",
      "s3:PutBucket*",
      "s3:GetAccelerateConfiguration",
      "s3:PutAccelerateConfiguration",
      "s3:GetObjectLockConfiguration",
      "s3:PutObjectLockConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:PutReplicationConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:GetEncryptionConfiguration",
      "s3:PutEncryptionConfiguration",
      "s3:ListAllMyBuckets",
    ]
    resources = [
      "arn:aws:s3:::skylab-*",
      "arn:aws:s3:::skylab-*/*",
    ]
  }

  # RDS — databases.
  statement {
    sid    = "RDS"
    effect = "Allow"
    actions = [
      "rds:*",
    ]
    resources = ["*"]
  }

  # KMS — read-only; Crossplane doesn't create keys. Needed for
  # EKS encryption and RDS encryption lookups.
  statement {
    sid    = "KMSRead"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:ListKeys",
      "kms:ListAliases",
      "kms:ListResourceTags",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "crossplane_aws" {
  name        = var.policy_name
  description = "Permissions for the Crossplane provider-aws role to manage Skylab's AWS resources."
  policy      = data.aws_iam_policy_document.crossplane_aws.json
}
