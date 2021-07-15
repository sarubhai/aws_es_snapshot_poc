# Name: lambda_invocation.tf
# Owner: Saurav Mitra
# Description: This terraform config will execute the lambda function lambda-es-backup

# Invoke Lambda Function
data "aws_lambda_invocation" "lambda_invoke" {
  function_name = aws_lambda_function.lambda_es_backup.function_name

  input = <<JSON
{}
JSON
}
