##################################
#          SG Variables          #
##################################
variable "data_sg_name" {
  type        = string
  default     = "data"
  description = "Name of security group."
}

variable "data_sg_description" {
  type        = string
  default     = "Security group for data tier with mysql port open."
  description = "Description of security group."
}

variable "data_sg_egress_with_cidr_blocks" {
  type = list(any)
  default = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  description = "List of computed egress rules to create where 'cidr_blocks' is used."
}

##################################
#          DB Variables          #
##################################
variable "db_identifier" {
  type        = string
  default     = "datadb"
  description = "The name of the RDS instance."
}

variable "db_engine" {
  type        = string
  default     = "mysql"
  description = "The database engine to use."
}

variable "db_engine_version" {
  type        = string
  default     = "8.0"
  description = "The engine version to use."
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.small"
  description = "The instance type of the RDS instance."
}

variable "db_allocated_storage" {
  type        = number
  default     = 5
  description = "The allocated storage in gigabytes."
}

variable "db_name" {
  type        = string
  default     = "datadb"
  description = "The DB name to create. If omitted, no database is created initially."
}

variable "db_username" {
  type        = string
  default     = "admin"
  description = "Username for the master DB user."
}

variable "db_port" {
  type        = string
  default     = "3306"
  description = "The port on which the DB accepts connections."
}

variable "db_iam_db_auth_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether or not the mappings of AWS Identity and Access Management (IAM) accounts to database accounts are enabled."
}

variable "db_maintenance_window" {
  type        = string
  default     = "Mon:00:00-Mon:03:00"
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
}

variable "db_backup_window" {
  type        = string
  default     = "03:00-06:00"
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window."
}

variable "db_monitoring_interval" {
  type        = string
  default     = "30"
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0."
}

variable "db_monitoring_role_name" {
  type        = string
  default     = "ThreeTierRDSMonitoringRole"
  description = "Name of the IAM role which will be created when create_monitoring_role is enabled."
}

variable "db_create_monitoring_role" {
  type        = bool
  default     = true
  description = "Create IAM role with a defined name that permits RDS to send enhanced monitoring metrics to CloudWatch Logs."
}

variable "db_family" {
  type        = string
  default     = "mysql8.0"
  description = "The family of the DB parameter group."
}

variable "db_major_engine_version" {
  type        = string
  default     = "8.0"
  description = "Specifies the major version of the engine that this option group should be associated with."
}

variable "db_deletion_protection" {
  type        = bool
  default     = false
  description = "The database can't be deleted when this value is set to true."
}

variable "db_create_db_subnet_group" {
  type        = bool
  default     = true
  description = "Whether to create a database subnet group."
}

variable "db_parameters" {
  type = list(any)
  default = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
  description = "A list of DB parameters (map) to apply"
}

variable "db_options" {
  type = list(any)
  default = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
  description = "A list of Options to apply."
}

variable "db_skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted."
}

variable "db_tags" {
  type = map(any)
  default = {
    Terraform   = "true"
    Environment = "dev"
    Workload    = "3Tier-APP"
    Component   = "database"
  }
  description = "A map of tags to add to all resources."
}
