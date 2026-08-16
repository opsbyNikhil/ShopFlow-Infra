resource "aws_launch_template" "template" {
  for_each = var.asg_info

  name = each.value.asg_name

  image_id      = each.value.ami
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  network_interfaces {
    associate_public_ip_address = each.value.associate_public_ip_address
    security_groups             = each.value.vpc_security_group_ids
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = each.value.asg_name
      Tier = each.value.tier
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  for_each = var.asg_info

  name = each.value.asg_name

  min_size         = each.value.min_size
  desired_capacity = each.value.desired_capacity
  max_size         = each.value.max_size

  vpc_zone_identifier = each.value.subnet_ids

  health_check_type         = "EC2"
  health_check_grace_period = each.value.health_check_grace_period

  launch_template {
    id      = aws_launch_template.template[each.key].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = each.value.asg_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = each.value.tier
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_policy" "scale_out" {
  for_each = var.asg_info

  name = "${each.value.tier}-scale-out"

  autoscaling_group_name = aws_autoscaling_group.asg[each.key].name

  policy_type     = "StepScaling"
  adjustment_type = "ChangeInCapacity"

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_lower_bound = 0
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  for_each = var.asg_info

  alarm_name = "${each.value.tier}-cpu-high"

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  period              = 60

  metric_name = "CPUUtilization"
  namespace   = "AWS/EC2"
  statistic   = "Average"

  threshold = each.value.cpu_threshold

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg[each.key].name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_out[each.key].arn
  ]

  treat_missing_data = "notBreaching"
}

