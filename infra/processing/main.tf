
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

module "processing" {
  source = "../../modules/processing"
}
