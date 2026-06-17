output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}
output "public_subnet_ids" {
  description = "IDs of the created public subnets"
  value       = module.vpc.public_subnet_ids
}
output "private_subnet_ids" {
  description = "IDs of the created private subnets"
  value       = module.vpc.private_subnet_ids
}
output "kops_state_bucket_name" {
  value = module.kops_state_bucket.bucket_name
}

output "route53_zone_id" {
  value = module.dns.zone_id
}

output "route53_name_servers" {
  value = module.dns.name_servers
}