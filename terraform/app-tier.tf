##################################
#             Locals             #
##################################
locals {
  app_ami = {
    most_recent = var.app_ami_most_recent
    filter_name = var.app_ami_filter_name
    owners      = var.app_ami_owner
  }
  app_asg = {
    name                = var.app_asg_name
    min_size            = var.app_asg_min_size
    max_size            = var.app_asg_max_size
    desired_capacity    = var.app_asg_desired_capacity
    health_check_type   = var.app_asg_health_check_type
    vpc_zone_identifier = module.vpc.private_subnets
    instance_refresh = {
      strategy = var.app_asg_instance_refresh_strategy
      preferences = {
        checkpoint_delay       = var.app_asg_instref_pref_checkpoint_delay
        checkpoint_percentages = var.app_asg_instref_pref_checkpoint_percentages
        instance_warmup        = var.app_asg_instref_pref_instance_warmup
        min_healthy_percentage = var.app_asg_instref_pref_min_healthy_percentage
        max_healthy_percentage = var.app_asg_instref_pref_max_healthy_percentage
      }
      triggers = var.app_asg_instance_refresh_triggers
    }
    launch_template_name        = var.app_asg_launch_template_name
    launch_template_description = var.app_asg_launch_template_description
    update_default_version      = var.app_asg_update_default_version
    image_id                    = data.aws_ami.app.id
    user_data                   = filebase64("${path.module}/app_user_data.sh")
    instance_type               = var.app_asg_instance_type
    ebs_optimized               = var.app_asg_ebs_optimized
    enable_monitoring           = var.app_asg_enable_monitoring
    create_iam_instance_profile = var.app_asg_create_iam_instance_profile
    iam_role_name               = var.app_asg_iam_role_name
    iam_role_path               = var.app_asg_iam_role_path
    iam_role_description        = var.app_asg_iam_role_description
    iam_role_tags               = var.app_asg_iam_role_tages
    iam_role_policies           = var.app_asg_iam_role_policies
    block_device_mappings = {
      ebs = {
        delete_on_termination = var.app_asg_blkdevmap_ebs_delete_on_termination
        encrypted             = var.app_asg_blkdevmap_ebs_encrypted
        volume_size           = var.app_asg_blkdevmap_ebs_volume_size
        volume_type           = var.app_asg_blkdevmap_ebs_volume_type
      }
    }
    tag_specifications = var.app_asg_tag_specifications
    tags               = var.app_asg_tags
  }
  app_alb = {
    name    = var.app_alb_name
    vpc_id  = module.vpc.vpc_id
    subnets = module.vpc.private_subnets
    tags    = var.app_alb_tags
  }
  app_sg = {
    name        = var.app_sg_name
    description = var.app_sg_description
  }
}
##################################
#          Data Sources          #
##################################
data "aws_ami" "app" {

  most_recent = local.app_ami.most_recent

  filter {
    name   = "name"
    values = local.app_ami.filter_name
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = local.app_ami.owners
}
##################################
#           Resources            #
##################################
module "app_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name        = local.app_sg.name
  description = local.app_sg.description
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
    {
      description              = "http from the security group of the App instance."
      rule                     = "http-80-tcp"
      source_security_group_id = module.app_alb.security_group_id
    },
  ]
}

module "app_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 7.4"

  name                = local.app_asg.name
  min_size            = local.app_asg.min_size
  max_size            = local.app_asg.max_size
  desired_capacity    = local.app_asg.desired_capacity
  health_check_type   = local.app_asg.health_check_type
  vpc_zone_identifier = module.vpc.private_subnets

  instance_refresh = {
    strategy = local.app_asg.instance_refresh.strategy
    preferences = {
      checkpoint_delay       = local.app_asg.instance_refresh.preferences.checkpoint_delay
      checkpoint_percentages = local.app_asg.instance_refresh.preferences.checkpoint_percentages
      instance_warmup        = local.app_asg.instance_refresh.preferences.instance_warmup
      min_healthy_percentage = local.app_asg.instance_refresh.preferences.min_healthy_percentage
      max_healthy_percentage = local.app_asg.instance_refresh.preferences.max_healthy_percentage
    }
    triggers = local.app_asg.instance_refresh.triggers
  }

  # Launch template
  launch_template_name        = local.app_asg.launch_template_name
  launch_template_description = local.app_asg.launch_template_description
  update_default_version      = local.app_asg.update_default_version

  image_id          = local.app_asg.image_id
  user_data         = local.app_asg.user_data
  instance_type     = local.app_asg.instance_type
  ebs_optimized     = local.app_asg.ebs_optimized
  enable_monitoring = local.app_asg.enable_monitoring

  # IAM role & instance profile
  create_iam_instance_profile = local.app_asg.create_iam_instance_profile
  iam_role_name               = local.app_asg.iam_role_name
  iam_role_path               = local.app_asg.iam_role_path
  iam_role_description        = local.app_asg.iam_role_description
  iam_role_tags               = local.app_asg.iam_role_tags
  iam_role_policies           = local.app_asg.iam_role_policies

  security_groups = [module.app_sg.security_group_id]

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/sda1"
      no_device   = 0
      ebs = {
        delete_on_termination = local.app_asg.block_device_mappings.ebs.delete_on_termination
        encrypted             = local.app_asg.block_device_mappings.ebs.encrypted
        volume_size           = local.app_asg.block_device_mappings.ebs.volume_size
        volume_type           = local.app_asg.block_device_mappings.ebs.volume_type
      }
    }
  ]

  target_group_arns = [module.app_alb.target_groups.app.arn]

  tag_specifications = local.app_asg.tag_specifications
  tags               = local.app_asg.tags
}

module "app_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.9"

  name                       = local.app_alb.name
  vpc_id                     = local.app_alb.vpc_id
  subnets                    = local.app_alb.subnets
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    web_alb_http = {
      from_port                    = 80
      to_port                      = 80
      ip_protocol                  = "tcp"
      description                  = "HTTP web load balancer traffic"
      referenced_security_group_id = module.web_alb.security_group_id
    }
    web_alb_https = {
      from_port                    = 443
      to_port                      = 443
      ip_protocol                  = "tcp"
      description                  = "HTTPS web load balancer traffic"
      referenced_security_group_id = module.web_alb.security_group_id
    }
    web_http = {
      from_port                    = 80
      to_port                      = 80
      ip_protocol                  = "tcp"
      description                  = "HTTP web instances traffic"
      referenced_security_group_id = module.web_sg.security_group_id
    }
    web_https = {
      from_port                    = 443
      to_port                      = 443
      ip_protocol                  = "tcp"
      description                  = "HTTPS web instances traffic"
      referenced_security_group_id = module.web_sg.security_group_id
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
        target_group_key = "app"
      }
    }
  }

  target_groups = {
    app = {
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

  tags = local.app_alb.tags
}