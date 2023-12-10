variable "region" {
  description = "Region where to place resources"
  default     = "us-west-2"
  type        = string
}

variable "email" {
  description = "Email to send SNS notifications to"
  type        = string
}

