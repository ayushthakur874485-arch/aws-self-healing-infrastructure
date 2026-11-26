resource "aws_cloudwatch_metric_alarm" "system_check_failed" {
  alarm_name          = "self-healing-infra-system-check-failed"
  alarm_description   = "AWS hardware/host problem: auto-recover the instance"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_System"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.app_server.id
  }

  alarm_actions = [
    "arn:aws:automate:${data.aws_region.current.region}:ec2:recover",
    aws_sns_topic.alerts.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "instance_check_failed" {
  alarm_name          = "self-healing-infra-instance-check-failed"
  alarm_description   = "OS-level problem (hung or unreachable): reboot the instance"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed_Instance"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.app_server.id
  }

  alarm_actions = [
    "arn:aws:automate:${data.aws_region.current.region}:ec2:reboot",
    aws_sns_topic.alerts.arn
  ]
}