# Shared object storage for the three cluster-side consumers:
#   - Loki (logs)
#   - Tempo (traces)
#   - TechDocs (Backstage docs)
#
# One account-local CMK encrypts all three. Loki and Tempo age out to
# GLACIER_IR after 90 days; TechDocs is left as-is because docs persist.

resource "aws_kms_key" "storage" {
  description             = "Encrypts the Skylab storage buckets (Loki, Tempo, TechDocs)."
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_kms_alias" "storage" {
  name          = "alias/skylab-storage"
  target_key_id = aws_kms_key.storage.id
}

locals {
  observability_lifecycle = [
    {
      id     = "age-out-to-glacier-ir"
      status = "Enabled"
      filter = {}

      transition = [{
        days          = 90
        storage_class = "GLACIER_IR"
      }]

      noncurrent_version_expiration = {
        noncurrent_days = 90
      }

      abort_incomplete_multipart_upload_days = 7
    },
  ]
}

module "loki" {
  source = "../../modules/aws-object-storage"

  bucket_name     = "${var.bucket_name_prefix}-loki"
  kms_key_arn     = aws_kms_key.storage.arn
  lifecycle_rules = local.observability_lifecycle

  tags = {
    "skylab.io/consumer" = "loki"
  }
}

module "tempo" {
  source = "../../modules/aws-object-storage"

  bucket_name     = "${var.bucket_name_prefix}-tempo"
  kms_key_arn     = aws_kms_key.storage.arn
  lifecycle_rules = local.observability_lifecycle

  tags = {
    "skylab.io/consumer" = "tempo"
  }
}

module "techdocs" {
  source = "../../modules/aws-object-storage"

  bucket_name = "${var.bucket_name_prefix}-techdocs"
  kms_key_arn = aws_kms_key.storage.arn

  tags = {
    "skylab.io/consumer" = "techdocs"
  }
}
