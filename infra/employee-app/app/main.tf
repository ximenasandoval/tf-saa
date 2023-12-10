
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

module "app" {
  source        = "../../../modules/employee-app/app"
  subnet_1_name = "Public subnet 1"
  subnet_2_name = "Public subnet 2"
  vpc_name      = "app-vpc"
  bucket_name   = "employee-photo-bucket-xs-2023"
}
