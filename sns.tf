# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "web-server-alerts"
}

# SNS Subscription (Replace with your email)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "devopsconsultantsv@gmail.com" # Replace with your email
}