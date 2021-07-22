# Name: event_rule_snapshot_expiry.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Event Bridge rules to schedule lambda functions for ES Snapshot Expiry

resource "aws_cloudwatch_event_rule" "event_rule_snapshot_expiry" {
  name                = "event-rule-snapshot-expiry"
  description         = "Schedule ES Snapshot Backup Expiry"
  schedule_expression = "cron(0 22 * * *)"
  is_enabled          = true

  tags = {
    Name  = "${var.prefix}-event-rule-snapshot-expiry"
    Owner = var.owner
  }
}

resource "aws_cloudwatch_event_target" "target_lambda_snapshot_expiry" {
  rule = aws_cloudwatch_event_rule.event_rule_snapshot_expiry.id
  arn  = aws_lambda_function.lambda_snapshot_expiry.arn

  input = "{}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_snapshot_expiry" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_snapshot_expiry.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule_snapshot_expiry.arn
}
