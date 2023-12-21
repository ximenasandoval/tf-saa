
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

module "open-search" {
  source     = "../../modules/open-search"
  ip_address = var.ip_address
}
