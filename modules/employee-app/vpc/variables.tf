variable "region" {
  description = "Region to create resources in"
  default     = "us-west-2"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block to use for VPC creation"
  type        = string
}

variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 2
}
