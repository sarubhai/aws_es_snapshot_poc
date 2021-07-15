# Name: lambda_function.tf
# Owner: Saurav Mitra
# Description: This terraform config will create lambda function to setup Elasticsearch Backup to S3

resource "aws_lambda_function" "lambda_es_backup" {
  function_name = "lambda-es-backup"
  description   = "Setup Elasticsearch Backup to S3"
  memory_size   = 128
  timeout       = 120
  runtime       = "python3.7"
  role          = aws_iam_role.lambda_exec_role.arn

  vpc_config {
    subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnet_id
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  layers           = [aws_lambda_layer_version.requests_layer.arn, aws_lambda_layer_version.requests_aws4auth_layer.arn]
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
  handler          = "lambda_function.lambda_handler"

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
    Name  = "${var.prefix}-lambda-es-backup"
    Owner = var.owner
  }
}

resource "aws_lambda_function_event_invoke_config" "lambda_event_invoke" {
  function_name          = aws_lambda_function.lambda_es_backup.function_name
  maximum_retry_attempts = 0
  qualifier              = "$LATEST"
}
