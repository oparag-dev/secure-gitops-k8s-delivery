variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "capstone-project-novara"
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "azs" {
  description = "List of availability zones to use"
  type        = list(string)
}
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}
variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}
variable "enable_dns_support" {
  description = "Enable DNS support inside the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames inside the VPC"
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