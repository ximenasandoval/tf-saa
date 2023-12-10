
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

module "data-analytics" {
  source = "../../modules/data-analytics"
}
