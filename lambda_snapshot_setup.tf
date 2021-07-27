# Name: lambda_snapshot_setup.tf
# Owner: Saurav Mitra
# Description: This terraform config will create lambda function to setup Elasticsearch S3 based Snapshot Repository

data "archive_file" "snapshot_setup" {
  type        = "zip"
  source_file = "${path.module}/snapshot_setup.py"
  output_path = "${path.module}/snapshot_setup.zip"
}

resource "aws_lambda_function" "lambda_snapshot_setup" {
  function_name = "lambda-snapshot-setup"
  description   = "Setup Elasticsearch Snapshot to S3"
  memory_size   = 128
  timeout       = 120
  runtime       = "python3.7"
  role          = aws_iam_role.lambda_exec_role.arn

  vpc_config {
    subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnet_id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  layers           = [aws_lambda_layer_version.requests_layer.arn, aws_lambda_layer_version.requests_aws4auth_layer.arn]
  filename         = data.archive_file.snapshot_setup.output_path
  source_code_hash = data.archive_file.snapshot_setup.output_base64sha256
  handler          = "snapshot_setup.lambda_handler"

  environment {
    variables = {
      S3_BUCKET         = "${var.prefix}-s3-es-bkp"
      REGION            = data.aws_region.current.name
      ELASTIC_HOSTNAME  = "https://${aws_elasticsearch_domain.es_domain.endpoint}"
      ELASTIC_USERNAME  = var.master_user_name
      ELASTIC_PASSWORD  = var.master_user_password
      LAMBDA_ROLE_ARN   = aws_iam_role.lambda_exec_role.arn
      SNAPSHOT_ROLE_ARN = aws_iam_role.es_snapshot_role.arn
    }
  }

  tags = {
    Name  = "${var.prefix}-lambda-snapshot-setup"
    Owner = var.owner
  }
}

resource "aws_lambda_function_event_invoke_config" "lambda_snapshot_setup_invoke" {
  function_name          = aws_lambda_function.lambda_snapshot_setup.function_name
  maximum_retry_attempts = 0
  qualifier              = "$LATEST"
}

resource "aws_cloudwatch_log_group" "log_snapshot_setup" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_snapshot_setup.function_name}"
  retention_in_days = 7

  tags = {
    Name  = "${var.prefix}-log-lambda-snapshot-setup"
    Owner = var.owner
  }
}
