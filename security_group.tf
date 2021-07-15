# Name: security_group.tf
# Owner: Saurav Mitra
# Description: This terraform config will create AWS Security Group for Elasticsearch Domain & Lambda Function
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group

# Create Lambda Security Group
resource "aws_security_group" "lambda_sg" {
  name        = "${var.prefix}_lambda_sg"
  description = "Security Group for Lambda Function"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.prefix}-lambda-sg"
    Owner = var.owner
  }
}

# Create Elasticsearch Security Group
resource "aws_security_group" "elastic_sg" {
  name        = "${var.prefix}_elastic_sg"
  description = "Security Group for Elasticsearch Domains"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.vpc_cidr_block]
  }

  ingress {
    description     = "TLS from Lambda Security Group"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.prefix}-elastic-sg"
    Owner = var.owner
  }
}
