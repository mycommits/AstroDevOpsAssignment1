##################################
#             Locals             #
##################################
locals {
  region = var.region

  vpc = {
    name                               = join("-", [var.name, var.region])
    cidr                               = var.vpc_cidr
    create_igw                         = var.vpc_create_igw
    enable_ipv6                        = var.vpc_enable_ipv6
    create_egress_only_igw             = var.vpc_create_egress_only_igw
    create_database_subnet_group       = var.vpc_create_database_subnet_group
    azs                                = lookup(var.vpc_azs, var.region)
    public_subnets                     = var.vpc_public_subnets
    public_subnet_names                = [join("-", [var.name, var.region, "public"])]
    private_subnet_names               = [join("-", [var.name, var.region, "private"])]
    private_subnets                    = var.vpc_private_subnets
    enable_nat_gateway                 = var.vpc_enable_nat_gateway
    single_nat_gateway                 = var.vpc_single_nat_gateway
    nat_gateway_destination_cidr_block = var.vpc_nat_gateway_destination_cidr_block
    enable_dns_support                 = var.vpc_enable_dns_support
    enable_dns_hostnames               = var.vpc_enable_dns_hostnames
    map_public_ip_on_launch            = var.vpc_map_public_ip_on_launch

    igw_tags = {
      Name = join("-", [var.name, var.region, "igw"])
    }
    nat_gateway_tags = {
      Name = join("-", [var.name, var.region, "natgw"])
    }
    public_subnet_tags = {
      Type = "internet"
    }
    private_subnet_tags = {
      Type = "internal"
    }
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Workload    = "3Tier-APP"
    }
  }
}
##################################
#           Resources            #
##################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5"

  name                         = local.vpc.name
  cidr                         = local.vpc.cidr
  create_igw                   = local.vpc.create_igw
  enable_ipv6                  = local.vpc.enable_ipv6
  create_egress_only_igw       = local.vpc.create_egress_only_igw
  create_database_subnet_group = local.vpc.create_database_subnet_group

  azs                     = local.vpc.azs
  public_subnets          = local.vpc.public_subnets
  public_subnet_names     = local.vpc.public_subnet_names
  private_subnets         = local.vpc.private_subnets
  private_subnet_names    = local.vpc.private_subnet_names
  enable_nat_gateway      = local.vpc.enable_nat_gateway
  single_nat_gateway      = local.vpc.single_nat_gateway
  enable_dns_support      = local.vpc.enable_dns_support
  enable_dns_hostnames    = local.vpc.enable_dns_hostnames
  map_public_ip_on_launch = local.vpc.map_public_ip_on_launch

  igw_tags            = local.vpc.igw_tags
  nat_gateway_tags    = local.vpc.nat_gateway_tags
  public_subnet_tags  = local.vpc.public_subnet_tags
  private_subnet_tags = local.vpc.private_subnet_tags
  tags                = local.vpc.tags
}