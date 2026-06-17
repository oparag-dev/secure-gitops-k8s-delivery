output "kops_state_store" {
  description = "kOps state store URL."
  value       = "s3://${aws_s3_bucket.kops_state.bucket}"
}

