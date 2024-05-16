##################################
#          AMI Variables         #
##################################
variable "app_ami_most_recent" {
  type        = bool
  default     = true
  description = "If more than one result is returned, use the most recent AMI."
}

variable "app_ami_filter_name" {
  type        = list(any)
  default     = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  description = "The list of AMI image full names."
}

variable "app_ami_owner" {
  type        = list(any)
  default     = ["amazon"]
  description = "The list of AMI image owners."
}
##################################
#  Auto Scaling Group Variables  #
##################################
variable "app_asg_name" {
  type        = string
  default     = "app"
  description = "Name used across the resources created."
}

variable "app_asg_min_size" {
  type        = number
  default     = 1
  description = "The minimum size of the autoscaling group."
}

variable "app_asg_max_size" {
  type        = number
  default     = 1
  description = "The maximum size of the autoscaling group."
}

variable "app_asg_desired_capacity" {
  type        = number
  default     = 1
  description = "The number of Amazon EC2 instances that should be running in the autoscaling group."
}

variable "app_asg_health_check_type" {
  type        = string
  default     = "ELB"
  description = "Controls how health checking is done, 'ELB' or 'EC2'."
}

variable "app_asg_instance_refresh_strategy" {
  type        = string
  default     = "Rolling"
  description = "Strategy to use for instance refresh. The only allowed value is Rolling."
}

variable "app_asg_instref_pref_checkpoint_delay" {
  type        = number
  default     = 600
  description = "Number of seconds to wait after a checkpoint."
}

variable "app_asg_instref_pref_checkpoint_percentages" {
  type        = list(any)
  default     = [35, 70, 100]
  description = "List of percentages for each checkpoint. Values must be unique and in ascending order. To replace all instances, the final number must be 100."
}

variable "app_asg_instref_pref_instance_warmup" {
  type        = number
  default     = 300
  description = "Number of seconds until a newly launched instance is configured and ready to use. Default behavior is to use the Auto Scaling Group's health check grace period."
}

variable "app_asg_instref_pref_min_healthy_percentage" {
  type        = number
  default     = 50
  description = "Amount of capacity in the Auto Scaling group that must remain healthy during an instance refresh to allow the operation to continue, as a percentage of the desired capacity of the Auto Scaling group."
}

variable "app_asg_instref_pref_max_healthy_percentage" {
  type        = number
  default     = 100
  description = "Amount of capacity in the Auto Scaling group that can be in service and healthy, or pending, to support your workload when an instance refresh is in place, as a percentage of the desired capacity of the Auto Scaling group. Values must be between 100 and 200."
}

variable "app_asg_instance_refresh_triggers" {
  type        = list(any)
  default     = ["tag"]
  description = "Set of additional property names that will trigger an Instance Refresh. A refresh will always be triggered by a change in any of launch_configuration, launch_template, or mixed_instances_policy."
}

variable "app_asg_launch_template_name" {
  type        = string
  default     = "app"
  description = "Name of launch template to be created."
}

variable "app_asg_launch_template_description" {
  type        = string
  default     = "Launch template of the app tier of 3 tier application."
  description = "description"
}

variable "app_asg_update_default_version" {
  type        = bool
  default     = true
  description = "Whether to update Default Version each update."
}

variable "app_asg_instance_type" {
  type        = string
  default     = "t3.micro"
  description = "The type of the instance."
}

variable "app_asg_ebs_optimized" {
  type        = bool
  default     = true
  description = "If true, the launched EC2 instance will be EBS-optimized."
}

variable "app_asg_enable_monitoring" {
  type        = bool
  default     = true
  description = "Enables/disables detailed monitoring."
}

variable "app_asg_create_iam_instance_profile" {
  type        = bool
  default     = true
  description = "Determines whether an IAM instance profile is created or to use an existing IAM instance profile"
}

variable "app_asg_iam_role_name" {
  type        = string
  default     = "app"
  description = "Name to use on IAM role created."
}

variable "app_asg_iam_role_path" {
  type        = string
  default     = "/ec2/3tier-app/"
  description = "IAM role path."
}

variable "app_asg_iam_role_description" {
  type        = string
  default     = "To grant the necessary privileges to the app component in the 3-tier application workload."
  description = "Description of the role."
}

variable "app_asg_iam_role_tages" {
  type = map(any)
  default = {
    CustomIamRole = "Yes"
  }
  description = "A map of additional tags to add to the IAM role created"
}

variable "app_asg_iam_role_policies" {
  type = map(any)
  default = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  description = "IAM policies to attach to the IAM role"
}

variable "app_asg_blkdevmap_ebs_delete_on_termination" {
  type        = bool
  default     = true
  description = "Whether the volume should be destroyed on instance termination."
}

variable "app_asg_blkdevmap_ebs_encrypted" {
  type        = bool
  default     = true
  description = "Enables EBS encryption on the volume."
}

variable "app_asg_blkdevmap_ebs_volume_size" {
  type        = number
  default     = 20
  description = "The size of the volume in gigabytes."
}

variable "app_asg_blkdevmap_ebs_volume_type" {
  type        = string
  default     = "gp2"
  description = "The volume type. Can be one of standard, gp2, gp3, io1, io2, sc1 or st1."
}

variable "app_asg_tag_specifications" {
  type = list(any)
  default = [
    {
      resource_type = "instance"
      tags          = { Name = "app" }
    },
    {
      resource_type = "volume"
      tags          = { Name = "app" }
    }
  ]
  description = "The tags to apply to the resources during launch."
}

variable "app_asg_tags" {
  type = map(any)
  default = {
    Terraform   = "true"
    Environment = "dev"
    Workload    = "3Tier-APP"
    Component   = "app"
  }
  description = "All tags for the ASG."
}
##################################
#          ALB Variables         #
##################################

variable "app_alb_name" {
  type        = string
  default     = "app"
  description = "The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen."
}

variable "app_alb_tags" {
  type = map(any)
  default = {
    Terraform   = "true"
    Environment = "dev"
    Workload    = "3Tier-APP"
    Component   = "app-alb"
  }
  description = "A map of tags to add to all resources."
}
##################################
#          SG Variables          #
##################################
variable "app_sg_name" {
  type        = string
  default     = "app"
  description = "Name of security group"
}

variable "app_sg_description" {
  type        = string
  default     = "Security group for app tier with HTTP ports open."
  description = "Description of security group."
}
