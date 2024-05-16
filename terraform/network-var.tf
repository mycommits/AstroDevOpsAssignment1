## Global Variables
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS Region where the provider will operate."
}

## VPC Specific Variables
variable "name" {
  type        = string
  default     = "Dev-3TierApp"
  description = "Name to be used on all the resources as identifier."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.20.0.0/21"
  description = "The IPv4 CIDR block for the VPC."
}

variable "vpc_create_igw" {
  type        = bool
  default     = true
  description = "Controls if an Internet Gateway is created for public subnets and the related routes that connect them."
}

variable "vpc_enable_ipv6" {
  type        = bool
  default     = false
  description = "Requests an Amazon-provided IPv6 CIDR block with a /56 prefix length for the VPC. You cannot specify the range of IP addresses, or the size of the CIDR block."
}

variable "vpc_create_egress_only_igw" {
  type        = bool
  default     = false
  description = "Controls if an Egress Only Internet Gateway is created and its related routes."
}

variable "vpc_create_database_subnet_group" {
  type        = bool
  default     = false
  description = "Controls if database subnet group should be created (n.b. database_subnets must also be set)."
}

variable "vpc_azs" {
  type = map(any)
  default = {
    "ap-southeast-1" = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"],
    "us-east-1"      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
  description = "A list of availability zones names or ids in regions."
}

variable "vpc_public_subnets" {
  type        = list(any)
  default     = ["10.20.0.0/24", "10.20.1.0/24"]
  description = "A list of public subnets inside the VPC."
}

variable "vpc_private_subnets" {
  type        = list(any)
  default     = ["10.20.4.0/24", "10.20.5.0/24"]
  description = "A list of private subnets inside the VPC."
}

variable "vpc_enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Should be true if you want to provision NAT Gateways for each of your private networks."
}

variable "vpc_single_nat_gateway" {
  type        = bool
  default     = true
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks."
}

variable "vpc_nat_gateway_destination_cidr_block" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Used to pass a custom destination route for private NAT Gateway."
}

variable "vpc_enable_dns_support" {
  type        = bool
  default     = true
  description = "Should be true to enable DNS support in the VPC."
}

variable "vpc_enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "Should be true to enable DNS hostnames in the VPC."
}

variable "vpc_map_public_ip_on_launch" {
  type        = bool
  default     = true
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address."
}
