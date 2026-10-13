output "kms_key_arn" {
  value       = aws_kms_key.storage.arn
  description = "ARN of the CMK that encrypts every bucket in this stack."
}

output "kms_key_alias" {
  value       = aws_kms_alias.storage.name
  description = "Alias of the storage CMK."
}

output "loki_bucket_name" {
  value       = module.loki.bucket_id
  description = "Name of the Loki chunk bucket. Reference from skylab-gitops Loki values."
}

output "loki_bucket_arn" {
  value       = module.loki.bucket_arn
  description = "ARN of the Loki bucket. Use to scope IAM policies on the Loki workload role."
}

output "tempo_bucket_name" {
  value       = module.tempo.bucket_id
  description = "Name of the Tempo trace bucket. Reference from skylab-gitops Tempo values."
}

output "tempo_bucket_arn" {
  value       = module.tempo.bucket_arn
  description = "ARN of the Tempo bucket. Use to scope IAM policies on the Tempo workload role."
}

output "techdocs_bucket_name" {
  value       = module.techdocs.bucket_id
  description = "Name of the TechDocs bucket. Reference from skylab-backstage TechDocs publisher config."
}

output "techdocs_bucket_arn" {
  value       = module.techdocs.bucket_arn
  description = "ARN of the TechDocs bucket. Use to scope IAM policies on the Backstage publisher role."
}
