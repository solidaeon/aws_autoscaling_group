output "asg_name" {
  value = aws_autoscaling_group.this.name
}

output "asg_arn" {
  value = aws_autoscaling_group.this.arn
}

output "asg_id" {
  value = aws_autoscaling_group.this.id
}

output "lt_name" {
  value = aws_launch_template.this.name
}

output "lt_arn" {
  value = aws_launch_template.this.arn
}

output "lt_id" {
  value = aws_launch_template.this.id
}