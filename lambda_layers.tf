# Name: lambda_layers.tf
# Owner: Saurav Mitra
# Description: This terraform config will create Lambda Layers

# Create Python Requests Layer
# https://github.com/psf/requests/tree/master/requests
resource "aws_lambda_layer_version" "requests_layer" {
  layer_name          = "requests"
  description         = "Python Requests Library Layer"
  filename            = "requests.zip"
  source_code_hash    = filebase64sha256("requests.zip")
  compatible_runtimes = ["python3.7"]
  license_info        = "Apache-2.0"
}

# Create Python AWS4Auth Layer
# https://github.com/tedder/requests-aws4auth
resource "aws_lambda_layer_version" "requests_aws4auth_layer" {
  layer_name          = "requests_aws4auth"
  description         = "Python AWS4Auth Library Layer"
  filename            = "requests_aws4auth.zip"
  source_code_hash    = filebase64sha256("requests_aws4auth.zip")
  compatible_runtimes = ["python3.7"]
  license_info        = "MIT"
}
