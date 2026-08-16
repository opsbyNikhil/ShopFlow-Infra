output "asg_ids" {
  value = {
    for name, asg in aws_autoscaling_group.asg :
    name => asg.id
  }
}

output "asg_names" {
  value = {
    for name, asg in aws_autoscaling_group.asg :
    name => asg.name
  }
}

output "asg_arns" {
  value = {
    for name, asg in aws_autoscaling_group.asg :
    name => asg.arn
  }
}

output "launch_template_ids" {
  value = {
    for name, template in aws_launch_template.template :
    name => template.id
  }
}

output "scale_out_policy_arns" {
  value = {
    for name, policy in aws_autoscaling_policy.scale_out :
    name => policy.arn
  }
}

output "cpu_alarm_names" {
  value = {
    for name, alarm in aws_cloudwatch_metric_alarm.cpu_high :
    name => alarm.alarm_name
  }
}