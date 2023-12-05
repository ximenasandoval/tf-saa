
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

module "app" {
  source      = "../../../modules/exercise-1/app"
  subnet_name = "Public subnet 1"
  vpc_name    = "app-vpc"
  bucket_name = "employee-photo-bucket-xs-2023"
}
