terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

module "vpc" {
  source     = "../../../modules/employee-app/vpc"
  name       = "app-vpc"
  cidr_block = "10.1.0.0/16"
}
