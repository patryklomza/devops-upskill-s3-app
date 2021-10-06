# Input variable definitions

variable "cidr_block" {
  description = "CIDR block of the VPC."
  type        = string
}

variable "owner_tag" {
  description = "Tag for an internet Gateway name"
  type        = string
}
variable "region" {
  description = "AZ for a subnet"
  type        = string
}

variable "public_subnet" {
  description = "A mapping of availability zones and cidr blocks for subnets."
  type        = map(string)
}

variable "s3_subnet" {
  description = "A mapping of availability zones and cidr blocks for subnets."
  type        = map(string)
}

variable "rds_subnet" {
  description = "A mapping of availability zones and cidr blocks for subnets."
  type        = map(string)
}

variable "azs" {
  description = "A list of available AZs."
  type        = list(string)
}
