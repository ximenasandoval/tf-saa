provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Provisioner = "terraform"
    }
  }
}
