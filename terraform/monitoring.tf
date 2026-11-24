variable "alert_email" {
  description = "Email address for alarm notifications"
  type        = string
}

resource "aws_sns_topic" "alerts" {
  name = "self-healing-infra-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "app_down" {
  alarm_name          = "self-healing-infra-app-down"
  alarm_description   = "Flask process (app.py) is not running"
  namespace           = "SelfHealingInfrastructure"
  metric_name         = "procstat_lookup_pid_count"
  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"

  dimensions = {
    InstanceId = aws_instance.app_server.id
    pattern    = "app.py"
    pid_finder = "native"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]
}