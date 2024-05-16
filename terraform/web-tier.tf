##################################
#             Locals             #
##################################
locals {
  web_ami = {
    most_recent = var.web_ami_most_recent
    filter_name = var.web_ami_filter_name
    owners      = var.web_ami_owner
  }
  web_asg = {
    name                = var.web_asg_name
    min_size            = var.web_asg_min_size
    max_size            = var.web_asg_max_size
    desired_capacity    = var.web_asg_desired_capacity
    health_check_type   = var.web_asg_health_check_type
    vpc_zone_identifier = module.vpc.public_subnets
    instance_refresh = {
      strategy = var.web_asg_instance_refresh_strategy
      preferences = {
        checkpoint_delay       = var.web_asg_instref_pref_checkpoint_delay
        checkpoint_percentages = var.web_asg_instref_pref_checkpoint_percentages
        instance_warmup        = var.web_asg_instref_pref_instance_warmup
        min_healthy_percentage = var.web_asg_instref_pref_min_healthy_percentage
        max_healthy_percentage = var.web_asg_instref_pref_max_healthy_percentage
      }
      triggers = var.web_asg_instance_refresh_triggers
    }
    launch_template_name        = var.web_asg_launch_template_name
    launch_template_description = var.web_asg_launch_template_description
    update_default_version      = var.web_asg_update_default_version
    image_id                    = data.aws_ami.web.id
    user_data                   = filebase64("${path.module}/web_user_data.sh")
    instance_type               = var.web_asg_instance_type
    ebs_optimized               = var.web_asg_ebs_optimized
    enable_monitoring           = var.web_asg_enable_monitoring
    create_iam_instance_profile = var.app_asg_create_iam_instance_profile
    iam_role_name               = var.app_asg_iam_role_name
    iam_role_path               = var.app_asg_iam_role_path
    iam_role_description        = var.app_asg_iam_role_description
    iam_role_tags               = var.app_asg_iam_role_tages
    iam_role_policies           = var.app_asg_iam_role_policies
    block_device_mappings = {
      ebs = {
        delete_on_termination = var.web_asg_blkdevmap_ebs_delete_on_termination
        encrypted             = var.web_asg_blkdevmap_ebs_encrypted
        volume_size           = var.web_asg_blkdevmap_ebs_volume_size
        volume_type           = var.web_asg_blkdevmap_ebs_volume_type
      }
    }
    tag_specifications = var.web_asg_tag_specifications
    tags               = var.web_asg_tags
  }
  web_alb = {
    name    = var.web_alb_name
    vpc_id  = module.vpc.vpc_id
    subnets = module.vpc.public_subnets
    tags    = var.web_alb_tags
  }
  web_sg = {
    name        = var.web_sg_name
    description = var.web_sg_description
  }
}
##################################
#          Data Sources          #
##################################
data "aws_ami" "web" {

  most_recent = local.web_ami.most_recent

  filter {
    name   = "name"
    values = local.web_ami.filter_name
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = local.web_ami.owners
}
##################################
#           Resources            #
##################################
module "web_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = local.web_sg.name
  description = local.web_sg.description
  vpc_id      = module.vpc.vpc_id

  egress_with_cidr_blocks = [
    {
      rule        = "all-all"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_source_security_group_id = [
    {
      description              = "http from Web ALB."
      rule                     = "http-80-tcp"
      source_security_group_id = module.web_alb.security_group_id
    },
  ]
}

module "web_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 7.4"

  name                = local.web_asg.name
  min_size            = local.web_asg.min_size
  max_size            = local.web_asg.max_size
  desired_capacity    = local.web_asg.desired_capacity
  health_check_type   = local.web_asg.health_check_type
  vpc_zone_identifier = local.web_asg.vpc_zone_identifier

  instance_refresh = {
    strategy = local.web_asg.instance_refresh.strategy
    preferences = {
      checkpoint_delay       = local.web_asg.instance_refresh.preferences.checkpoint_delay
      checkpoint_percentages = local.web_asg.instance_refresh.preferences.checkpoint_percentages
      instance_warmup        = local.web_asg.instance_refresh.preferences.instance_warmup
      min_healthy_percentage = local.web_asg.instance_refresh.preferences.min_healthy_percentage
      max_healthy_percentage = local.web_asg.instance_refresh.preferences.max_healthy_percentage
    }
    triggers = local.web_asg.instance_refresh.triggers
  }

  # Launch template
  launch_template_name        = local.web_asg.launch_template_name
  launch_template_description = local.web_asg.launch_template_description
  update_default_version      = local.web_asg.update_default_version

  image_id          = local.web_asg.image_id
  user_data         = local.web_asg.user_data
  instance_type     = local.web_asg.instance_type
  ebs_optimized     = local.web_asg.ebs_optimized
  enable_monitoring = local.web_asg.enable_monitoring

  # IAM role & instance profile
  create_iam_instance_profile = local.app_asg.create_iam_instance_profile
  iam_role_name               = local.app_asg.iam_role_name
  iam_role_path               = local.app_asg.iam_role_path
  iam_role_description        = local.app_asg.iam_role_description
  iam_role_tags               = local.app_asg.iam_role_tags
  iam_role_policies           = local.app_asg.iam_role_policies

  security_groups = [module.web_sg.security_group_id]

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/sda1"
      no_device   = 0
      ebs = {
        delete_on_termination = local.web_asg.block_device_mappings.ebs.delete_on_termination
        encrypted             = local.web_asg.block_device_mappings.ebs.encrypted
        volume_size           = local.web_asg.block_device_mappings.ebs.volume_size
        volume_type           = local.web_asg.block_device_mappings.ebs.volume_type
      }
    }
  ]

  target_group_arns = [module.web_alb.target_groups.web.arn]

  tag_specifications = local.web_asg.tag_specifications
  tags               = local.web_asg.tags
}

module "web_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.9"

  name                       = local.web_alb.name
  vpc_id                     = local.web_alb.vpc_id
  subnets                    = local.web_alb.subnets
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      forward = {
        target_group_key = "web"
      }
    }
  }

  target_groups = {
    web = {
      protocol                          = "HTTP"
      port                              = 80
      target_type                       = "instance"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true
      create_attachment                 = false

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        unhealthy_threshold = 6
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "80"
        protocol            = "HTTP"
        timeout             = 7
      }
    }
  }

  tags = local.web_alb.tags
}