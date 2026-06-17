variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-3"
}
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "capstone-project-novara"
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}
variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
}
variable "enable_dns_support" {
  description = "Enable DNS support inside the VPC"
  type        = bool
  default     = true
}
variable "nat_gateway_enabled" {
  description = "Whether to create NAT Gateway"
  type        = bool
  default     = true
}
variable "single_nat_gateway" {
  description = "Use one shared NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "kops_state_bucket_name" {
  description = "S3 bucket name for Kops state store"
  type        = string
  default     = "opara-kops-state"
}
variable "domain_name" {
  description = "Root domain name"
  type        = string
  default     = "oparatechstack.com"
}