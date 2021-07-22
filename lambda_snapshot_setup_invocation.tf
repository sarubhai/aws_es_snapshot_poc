# Name: lambda_snapshot_setup_invokation.tf
# Owner: Saurav Mitra
# Description: This terraform config will execute the lambda function lambda-snapshot-setup

# Invoke Lambda Function
data "aws_lambda_invocation" "lambda_snapshot_setup_invocation" {
  function_name = aws_lambda_function.lambda_snapshot_setup.function_name

  input = <<JSON
{}
JSON
}
