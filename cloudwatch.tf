resource "aws_cloudwatch_log_group" "eks_cluster_logs" {
  name              = "/aws/eks/${var.project_name}-cluster/cluster"
  retention_in_days = 90

  tags = {
    Name        = "${var.project_name}-eks-cluster-logs"
    Compliance  = "GDPR_PCI-DSS"
  }
}

resource "aws_cloudwatch_metric_alarm" "security_group_changes" {
  alarm_name          = "${var.project_name}-security-group-changes"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SecurityGroupEventCount"
  namespace           = "AWS/Events"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors changes to security groups"
  alarm_actions       = [aws_sns_topic.security_alerts.arn]

  tags = {
    Compliance = "GDPR_PCI-DSS"
  }
}

resource "aws_sns_topic" "security_alerts" {
  name = "${var.project_name}-security-alerts"

  tags = {
    Name        = "${var.project_name}-security-alerts"
    Compliance  = "GDPR_PCI-DSS"
  }
}
