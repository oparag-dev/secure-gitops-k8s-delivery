output "project_context" {
  description = "returned to the root"
  value       = local.project_context
}
output "common_tags" {
  value = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}