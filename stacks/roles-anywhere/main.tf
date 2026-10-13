# One trust anchor rooted at the step-ca CA cert, plus one profile+role
# per Skylab workload that needs short-lived AWS credentials.
#
# The step-ca root PEM is supplied via `step_ca_root_pem` (variable), not
# committed. Set via `-var-file=secrets.tfvars`, env var `TF_VAR_...`, or
# an AWS Secrets Manager data source — whatever matches your workflow.
# A placeholder PEM is NOT acceptable; `terraform apply` will fail with a
# non-x.509 input.

resource "aws_rolesanywhere_trust_anchor" "step_ca" {
  name    = "skylab-step-ca"
  enabled = true

  source {
    source_type = "CERTIFICATE_BUNDLE"
    source_data {
      x509_certificate_data = var.step_ca_root_pem
    }
  }
}

# Loki — writes chunks and indexes to its S3 bucket (storage stack).
module "loki" {
  source = "../../modules/roles-anywhere"

  trust_anchor_arn = aws_rolesanywhere_trust_anchor.step_ca.arn
  role_name        = "skylab-loki"
  profile_name     = "skylab-loki"
  description      = "Loki in the hub cluster. Writes chunks + indexes to its S3 bucket."

  allowed_subject_cns = ["loki.observability.svc"]

  # TODO: inline policy scoped to the Loki bucket once storage stack lands.
}

# Tempo — writes traces to its S3 bucket.
module "tempo" {
  source = "../../modules/roles-anywhere"

  trust_anchor_arn = aws_rolesanywhere_trust_anchor.step_ca.arn
  role_name        = "skylab-tempo"
  profile_name     = "skylab-tempo"
  description      = "Tempo in the hub cluster. Writes traces to its S3 bucket."

  allowed_subject_cns = ["tempo.observability.svc"]

  # TODO: inline policy scoped to the Tempo bucket once storage stack lands.
}

# External Secrets Operator — reads secrets from AWS Secrets Manager.
module "external_secrets" {
  source = "../../modules/roles-anywhere"

  trust_anchor_arn = aws_rolesanywhere_trust_anchor.step_ca.arn
  role_name        = "skylab-external-secrets"
  profile_name     = "skylab-external-secrets"
  description      = "ESO ClusterSecretStore for AWS Secrets Manager."

  allowed_subject_cns = ["external-secrets.external-secrets.svc"]

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
  ]
  # TODO: tighten to least-privilege once we know which secret prefixes ESO reads.
}

# Crossplane provider-aws — manages cloud resources from inside the cluster.
module "crossplane_aws" {
  source = "../../modules/roles-anywhere"

  trust_anchor_arn = aws_rolesanywhere_trust_anchor.step_ca.arn
  role_name        = "skylab-crossplane-aws"
  profile_name     = "skylab-crossplane-aws"
  description      = "Crossplane provider-aws. Reconciles EKS, VPC, S3, RDS, IAM."

  allowed_subject_cns = ["provider-aws.crossplane-system.svc"]

  # Scaffold: AdministratorAccess. TODO: narrow to the service scopes the
  # skylab-crossplane compositions actually use (eks, ec2, iam, s3, rds).
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
  ]
}
