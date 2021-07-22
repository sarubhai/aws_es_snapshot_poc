# Name: event_rule_snapshot_backup.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Event Bridge rules to schedule lambda functions for ES Snapshot Backup

resource "aws_cloudwatch_event_rule" "event_rule_snapshot_backup" {
  name                = "event-rule-snapshot-backup"
  description         = "Schedule ES Snapshot Backup Creation"
  schedule_expression = "cron(0 20 * * *)"
  is_enabled          = true

  tags = {
    Name  = "${var.prefix}-event-rule-snapshot-backup"
    Owner = var.owner
  }
}

resource "aws_cloudwatch_event_target" "target_lambda_snapshot_backup" {
  rule = aws_cloudwatch_event_rule.event_rule_snapshot_backup.id
  arn  = aws_lambda_function.lambda_snapshot_backup.arn

  input = "{}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_snapshot_backup" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_snapshot_backup.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule_snapshot_backup.arn
}
