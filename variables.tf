variable "aws_region_name" {
  default = "ap-northeast-1"
  description = "name of the aws region."
}

variable "project" {
  type = string
  description = "project code"
  default = "uap"
}

variable "namespace" {
  type = string
  description = "a string that prepends resources"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "key_name" {
  type = string
  default = ""
}

variable "user_data_base64" {
  type = string
  default = ""
}

variable "min_size" {
  default = 1
  description = "minimum ec2 count"
}

variable "max_size" {
  default = 1
  description = "maximum ec2 count"
}

variable "vpc_zone_identifier" {
  type = list(string)
}

variable "iam_instance_profile_arn" {
  description = "the arn of the instance profile to attach in the instance"
  type = string
  default = ""
}

variable "monitoring_enabled" {
  description = "to enanble monitoring"
  type = bool
  default = true
}

variable "linux_os" {
  default = "amazon"
  description = "a string that defines which linux os to be used."
}

variable "ec2_termination_protection" {
  type = bool
  default = true
  description = "toggles ec2 termination protection"
}

variable "ec2_ebs_optimized" {
  type = bool
  default = true
  description = "enables EBS block stotage"
}

variable "instance_initiated_shutdown_behavior" {
  type = string
  default = "terminate"
  description = "instance_initiated_shutdown_behavior"
}

variable "launch_template_version" {
  type = string
  default = ""
}

variable "vpc_security_group_ids" {
  type = list(string)
  default = []
}

variable "block_device_mappings" {
  description = "Specify volumes to attach to the instance besides the volumes specified by the AMI"

  type = list(object({
    device_name  = string
    no_device    = bool
    virtual_name = string
    ebs = object({
      delete_on_termination = bool
      encrypted             = bool
      iops                  = number
      kms_key_id            = string
      snapshot_id           = string
      volume_size           = number
      volume_type           = string
    })
  }))

  default = []
}

variable "placement" {
  description = "The placement specifications of the instances"

  type = object({
    affinity          = string
    availability_zone = string
    group_name        = string
    host_id           = string
    tenancy           = string
  })

  default = null
}

variable "instance_market_options" {
  description = "The market (purchasing) option for the instances"

  type = object({
    market_type = string
    spot_options = object({
      block_duration_minutes         = number
      instance_interruption_behavior = string
      max_price                      = number
      spot_instance_type             = string
      valid_until                    = string
    })
  })

  default = null
}
