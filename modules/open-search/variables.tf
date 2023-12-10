variable "region" {
  description = "Region where to place resources"
  default     = "us-west-2"
  type        = string
}

variable "ip_address" {
  description = "IP address to allow traffic from for Opensearch cluster"
  type        = string
}

