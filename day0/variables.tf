variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for subnet"
  default     = "us-east-1a"
}
