variable "subnet_1_name" {
  description = "Name of the subnet 1 to place EC2 instance in"
  type        = string
}

variable "subnet_2_name" {
  description = "Name of the subnet 1 to place EC2 instance in"
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
