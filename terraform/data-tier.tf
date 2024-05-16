##################################
#             Locals             #
##################################
locals {
  data_sg = {
    name                    = var.data_sg_name
    description             = var.data_sg_description
    egress_with_cidr_blocks = var.data_sg_egress_with_cidr_blocks
  }
  db = {
    identifier                          = var.db_identifier
    engine                              = var.db_engine
    engine_version                      = var.db_engine_version
    instance_class                      = var.db_instance_class
    allocated_storage                   = var.db_allocated_storage
    db_name                             = var.db_name
    username                            = var.db_username
    port                                = var.db_port
    iam_database_authentication_enabled = var.db_iam_db_auth_enabled
    maintenance_window                  = var.db_maintenance_window
    backup_window                       = var.db_backup_window
    monitoring_interval                 = var.db_monitoring_interval
    monitoring_role_name                = var.db_monitoring_role_name
    create_monitoring_role              = var.db_create_monitoring_role
    family                              = var.db_family
    major_engine_version                = var.db_major_engine_version
    create_db_subnet_group              = var.db_create_db_subnet_group
    parameters                          = var.db_parameters
    options                             = var.db_options
    deletion_protection                 = var.db_deletion_protection
    skip_final_snapshot                 = var.db_skip_final_snapshot
    tags                                = var.db_tags
  }
}
##################################
#           Resources            #
##################################
module "data_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = local.data_sg.name
  description = local.data_sg.description
  vpc_id      = module.vpc.vpc_id

  egress_with_cidr_blocks = local.data_sg.egress_with_cidr_blocks

  ingress_with_source_security_group_id = [
    {
      description              = "Allow mysql connections from the security group of the app instance."
      rule                     = "mysql-tcp"
      source_security_group_id = module.app_sg.security_group_id
    },
  ]
}

module "database" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.6"

  identifier = local.db.identifier

  engine            = local.db.engine
  engine_version    = local.db.engine_version
  instance_class    = local.db.instance_class
  allocated_storage = local.db.allocated_storage

  db_name  = local.db.db_name
  username = local.db.username
  port     = local.db.port

  create_db_subnet_group = local.db.create_db_subnet_group
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [module.data_sg.security_group_id]

  iam_database_authentication_enabled = local.db.iam_database_authentication_enabled

  maintenance_window = local.db.maintenance_window
  backup_window      = local.db.backup_window

  monitoring_interval    = local.db.monitoring_interval
  monitoring_role_name   = local.db.monitoring_role_name
  create_monitoring_role = local.db.create_monitoring_role

  family               = local.db.family
  major_engine_version = local.db.major_engine_version
  parameters           = local.db.parameters
  options              = local.db.options

  deletion_protection = local.db.deletion_protection
  skip_final_snapshot = local.db.skip_final_snapshot

  tags = local.db.tags
}