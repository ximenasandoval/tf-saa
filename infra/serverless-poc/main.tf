
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

module "serverless" {
  source = "../../modules/serverless-poc"
  email  = var.email
}
