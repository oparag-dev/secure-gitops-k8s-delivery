output "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "S3 bucket ARN for Terraform remote state."
  value       = aws_s3_bucket.terraform_state.arn
}

output "backend_config_example" {
  description = "Backend config to copy into terraform/root/backend.tf."
  value = {
    bucket       = aws_s3_bucket.terraform_state.bucket
    key          = "root/terraform.tfstate"
    region       = var.aws_region
    use_lockfile = true
  }
}