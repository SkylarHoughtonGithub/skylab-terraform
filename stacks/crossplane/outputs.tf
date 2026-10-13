output "policy_arn" {
  value       = aws_iam_policy.crossplane_aws.arn
  description = "ARN of the scoped Crossplane provider-aws policy."
}

output "policy_name" {
  value       = aws_iam_policy.crossplane_aws.name
  description = "Name of the policy. stacks/roles-anywhere looks it up by name."
}
