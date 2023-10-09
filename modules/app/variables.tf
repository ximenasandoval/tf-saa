variable "subnet_name" {
  description = "Name of the subnet to place EC2 instance in"
  type        = string

}

variable "vpc_name" {
  description = "Name of the vpc to place EC2 instance in"
  type        = string

}

variable "region" {
  description = "Region to create resources in"
  default     = "us-west-2"
  type        = string
}

variable "bucket_name" {
  description = "Bucket name for app"
  type        = string

}
