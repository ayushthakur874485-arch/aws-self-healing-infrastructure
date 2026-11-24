resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name        = "self-healing-infra-high-cpu"
  alarm_description = "Triggers when EC2 CPU utilization exceeds 80% for 2 consecutive minutes."

  namespace           = "SelfHealingInfrastructure"
  metric_name         = "cpu_usage_idle"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  comparison_operator = "LessThanThreshold"
  threshold           = 20

  dimensions = {
    InstanceId = aws_instance.app_server.id
    cpu        = "cpu-total"
  }

  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}