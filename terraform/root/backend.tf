terraform {
  backend "s3" {
    bucket         = "novara-terraform-state-unique"
    key            = "root/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "novara-terraform-locks"
    encrypt        = true
  }
}