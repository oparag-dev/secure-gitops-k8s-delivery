variable "project_name" {
  description = "Project name passed from root"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into passed from root"
  type        = string
}

variable "azs" {
  description = "Availability Zones to use passed from root"
  type        = list(string)
}

variable "environment" {
  description = "Environment to deploy into passed from root"
  type        = string
}