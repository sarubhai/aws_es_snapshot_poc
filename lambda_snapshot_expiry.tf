# Name: lambda_snapshot_expiry.tf
# Owner: Saurav Mitra
# Description: This terraform config will create lambda function to delete Elasticsearch Snapshot Backup

data "archive_file" "snapshot_expiry" {
  type        = "zip"
  source_file = "${path.module}/snapshot_expiry.py"
  output_path = "${path.module}/snapshot_expiry.zip"
}

resource "aws_lambda_function" "lambda_snapshot_expiry" {
  function_name = "lambda-snapshot-expiry"
  description   = "Delete Elasticsearch Snapshot Backup"
  memory_size   = 128
  timeout       = 120
  runtime       = "python3.7"
  role          = aws_iam_role.lambda_exec_role.arn

  vpc_config {
    subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnet_id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  layers           = [aws_lambda_layer_version.requests_layer.arn, aws_lambda_layer_version.requests_aws4auth_layer.arn]
  filename         = data.archive_file.snapshot_backup.output_path
  source_code_hash = data.archive_file.snapshot_backup.output_base64sha256
  handler          = "snapshot_expiry.lambda_handler"

  environment {
    variables = {
      ELASTIC_HOSTNAME = "https://${aws_elasticsearch_domain.es_domain.endpoint}"
      ELASTIC_USERNAME = var.master_user_name
      ELASTIC_PASSWORD = var.master_user_password
      RETENTION_DAYS   = 3
    }
  }

  tags = {
    Name  = "${var.prefix}-lambda-snapshot-expiry"
    Owner = var.owner
  }
}

resource "aws_lambda_function_event_invoke_config" "lambda_snapshot_expiry_invoke" {
  function_name          = aws_lambda_function.lambda_snapshot_expiry.function_name
  maximum_retry_attempts = 0
  qualifier              = "$LATEST"
}

resource "aws_cloudwatch_log_group" "log_snapshot_expiry" {
  name = "/aws/lambda/${aws_lambda_function.lambda_snapshot_expiry.function_name}"

  retention_in_days = 7
}
