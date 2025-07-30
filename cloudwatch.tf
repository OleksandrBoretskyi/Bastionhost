resource "aws_cloudwatch_metric_alarm" "ec2_status_check_alarm" {
  alarm_name          = "terraform-test-ec2-status-check-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  alarm_description   = "This metric monitors ec2 cpu utilization"
  dimensions = {
    InstanceId = aws_instance.target_host.id
  }
  alarm_actions = [aws_sns_topic.alarm_topic.arn]
  ok_actions    = [aws_sns_topic.alarm_topic.arn]
}

resource "aws_sns_topic" "alarm_topic" {
  name = "bastion-health-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

variable "alert_email" {
  type        = string
  description = "Email address to receive alerts"
}