# modules/object-storage

Reusable private S3 bucket wired for SSE-KMS, versioning, blocked public access, and an optional lifecycle policy. Caller must supply a customer-managed KMS key (`kms_key_arn`); SSE-S3 (`AES256`) is intentionally not an option because Trivy AWS-0132 flags it HIGH.

## Usage

```hcl
module "loki" {
  source = "../../modules/object-storage"

  bucket_name = "skylab-loki-${random_id.suffix.hex}"
  kms_key_arn = aws_kms_key.storage.arn

  lifecycle_rules = [
    {
      id     = "age-out"
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
```

## What it creates

- `aws_s3_bucket` with `force_destroy = false`
- `aws_s3_bucket_versioning` (default: Enabled)
- `aws_s3_bucket_server_side_encryption_configuration` using `aws:kms` with the supplied CMK and `bucket_key_enabled = true`
- `aws_s3_bucket_public_access_block` with all four blocks set to `true`
- `aws_s3_bucket_lifecycle_configuration` only when `lifecycle_rules` is non-empty

## Lifecycle rule shape

Each entry in `lifecycle_rules` mirrors the `aws_s3_bucket_lifecycle_configuration` rule block:

| Key | Type | Notes |
| --- | --- | --- |
| `id` | string | Required. Unique rule id. |
| `status` | string | `Enabled` or `Disabled`. |
| `filter` | object | Required by the AWS provider. Use `{}` for whole-bucket. `{ prefix = "foo/" }` for a prefix filter. |
| `transition` | list(object) | Optional. Each item: `{ days?, date?, storage_class }`. |
| `expiration` | object | Optional. `{ days?, date?, expired_object_delete_marker? }`. |
| `noncurrent_version_expiration` | object | Optional. `{ noncurrent_days, newer_noncurrent_versions? }`. |
| `abort_incomplete_multipart_upload_days` | number | Optional. Days before incomplete multipart uploads are aborted. |
