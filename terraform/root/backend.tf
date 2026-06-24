terraform {
  backend "s3" {
    bucket       = "taskapp-terraform-state-opara"
    key          = "root/terraform.tfstate"
    region       = "eu-west-3"
    use_lockfile = true
    encrypt      = true
  }
}