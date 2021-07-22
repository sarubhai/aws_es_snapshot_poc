# Name: lambda_snapshot_backup.tf
# Owner: Saurav Mitra
# Description: This terraform config will create lambda function to create Elasticsearch Snapshot Backup

resource "aws_lambda_function" "lambda_snapshot_backup" {
  function_name = "lambda-snapshot-backup"
  description   = "Create Elasticsearch Snapshot Backup"
  memory_size   = 128
  timeout       = 120
  runtime       = "python3.7"
  role          = aws_iam_role.lambda_exec_role.arn

  vpc_config {
    subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnet_id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  layers           = [aws_lambda_layer_version.requests_layer.arn, aws_lambda_layer_version.requests_aws4auth_layer.arn]
  filename         = "snapshot_backup.zip"
  source_code_hash = filebase64sha256("snapshot_backup.zip")
  handler          = "snapshot_backup.lambda_handler"

  environment {
    variables = {
      ELASTIC_HOSTNAME = "https://${aws_elasticsearch_domain.es_domain.endpoint}"
      ELASTIC_USERNAME = var.master_user_name
      ELASTIC_PASSWORD = var.master_user_password
    }
  }

  tags = {
    Name  = "${var.prefix}-lambda-snapshot-backup"
    Owner = var.owner
  }
}

resource "aws_lambda_function_event_invoke_config" "lambda_snapshot_backup_invoke" {
  function_name          = aws_lambda_function.lambda_snapshot_backup.function_name
  maximum_retry_attempts = 0
  qualifier              = "$LATEST"
}
