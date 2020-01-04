provider "aws" {
  region = var.aws_region_name
}
terraform {
  required_version = ">= 0.12.0"
}