# CloudWatch Log Group for System Logs
resource "aws_cloudwatch_log_group" "system_logs" {
  name = "/ec2/web-server/system-logs"
  retention_in_days = 30 # Logs will be retained for 30 days
}

# CloudWatch Log Group for Application Logs
resource "aws_cloudwatch_log_group" "application_logs" {
  name = "/ec2/web-server/application-logs"
  retention_in_days = 30
}

# CloudWatch Alarm for High CPU Utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name                = "web-server-high-cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300 # 5 minutes
  statistic                 = "Average"
  threshold                 = 80 # Alert if CPU > 80%
  alarm_actions             = [aws_sns_topic.alerts.arn]
  dimensions = {
    InstanceId = aws_instance.web_server.id
  }
}

# CloudWatch Alarm for HTTP Server Downtime
resource "aws_cloudwatch_metric_alarm" "http_downtime" {
  alarm_name                = "web-server-http-downtime"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = 1
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = 60 # 1 minute
  statistic                 = "Maximum"
  threshold                 = 1 # Alert if status check fails
  alarm_actions             = [aws_sns_topic.alerts.arn]
  dimensions = {
    InstanceId = aws_instance.web_server.id
  }
}