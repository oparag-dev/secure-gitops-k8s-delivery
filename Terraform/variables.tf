variable "aws_region" {
  description = "AWS region for project prerequisites."
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "kops_state_bucket" {
  description = "Globally unique S3 bucket name used by kOps as the cluster state store."
  type        = string
}

