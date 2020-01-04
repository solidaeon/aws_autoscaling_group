
data "aws_ami" "ami" {
  most_recent = true
  filter {
    name = "name"
    values = [local.ami_name_filter]
  }
  owners = local.ami_owners
}

resource "aws_launch_template" "this" {
  name_prefix = "${var.namespace}-"

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name  = lookup(block_device_mappings.value, "device_name", null)
      no_device    = lookup(block_device_mappings.value, "no_device", null)
      virtual_name = lookup(block_device_mappings.value, "virtual_name", null)

      dynamic "ebs" {
        for_each = flatten(list(lookup(block_device_mappings.value, "ebs", [])))
        content {
          delete_on_termination = lookup(ebs.value, "delete_on_termination", null)
          encrypted             = lookup(ebs.value, "encrypted", null)
          iops                  = lookup(ebs.value, "iops", null)
          kms_key_id            = lookup(ebs.value, "kms_key_id", null)
          snapshot_id           = lookup(ebs.value, "snapshot_id", null)
          volume_size           = lookup(ebs.value, "volume_size", null)
          volume_type           = lookup(ebs.value, "volume_type", null)
        }
      }
    }
  }

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_termination = var.ec2_termination_protection

  ebs_optimized = var.ec2_ebs_optimized

  iam_instance_profile {
    arn = var.iam_instance_profile_arn
  }

  vpc_security_group_ids = var.vpc_security_group_ids

  image_id = data.aws_ami.ami.id

  instance_type = var.instance_type

  key_name = var.key_name

  user_data = var.user_data_base64

  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  dynamic "instance_market_options" {
    for_each = var.instance_market_options != null ? [var.instance_market_options] : []
    content {
      market_type = lookup(instance_market_options.value, "market_type", null)

      dynamic "spot_options" {
        for_each = flatten(list(lookup(instance_market_options.value, "spot_options", [])))
        content {
          block_duration_minutes         = lookup(spot_options.value, "block_duration_minutes", null)
          instance_interruption_behavior = lookup(spot_options.value, "instance_interruption_behavior", null)
          max_price                      = lookup(spot_options.value, "max_price", null)
          spot_instance_type             = lookup(spot_options.value, "spot_instance_type", null)
          valid_until                    = lookup(spot_options.value, "valid_until", null)
        }
      }
    }
  }

  dynamic "placement" {
    for_each = var.placement != null ? [var.placement] : []
    content {
      affinity          = lookup(placement.value, "affinity", null)
      availability_zone = lookup(placement.value, "availability_zone", null)
      group_name        = lookup(placement.value, "group_name", null)
      host_id           = lookup(placement.value, "host_id", null)
      tenancy           = lookup(placement.value, "tenancy", null)
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = var.tags
  }

  tag_specifications {
    resource_type = "instance"
    tags = local.merged_tags
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "this" {
  name_prefix = var.namespace

  max_size = var.max_size
  min_size = var.min_size
  desired_capacity = var.min_size

  vpc_zone_identifier = var.vpc_zone_identifier

  launch_template {
    id = join("", aws_launch_template.this.*.id)
    version = var.launch_template_version != "" ? var.launch_template_version : join("", aws_launch_template.this.*.latest_version)
  }

  tags = flatten([
    for key in keys(local.merged_tags) :
    {
      key = key
      value = local.merged_tags[key]
      propagate_at_launch = true
    }
  ])

}