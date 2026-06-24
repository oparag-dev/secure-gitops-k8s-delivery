project_name = "taskapp"
environment  = "prod"
aws_region   = "eu-west-3"

kops_state_bucket_name = "taskapp-kops-state-opara"

domain_name = "oparatechstack.com"

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "eu-west-3a",
  "eu-west-3b",
  "eu-west-3c"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24",
  "10.0.3.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24",
  "10.0.13.0/24"
]