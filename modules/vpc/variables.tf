variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC creation"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR block for subnets creation"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR block for subnets creation"
  type        = list(string)
}


variable "availability_zones" {
  description = "availability zone for vpc and each subnet"
  type        = list(string)
}
