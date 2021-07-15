# Name: iam_role.tf
# Owner: Saurav Mitra
# Description: This terraform config will create 2 IAM Roles
# 1 IAM role to delegate permissions to Amazon ES to allow access to the S3 bucket
# 1 for Lambda function to setup ES Snapshot
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role

resource "aws_iam_role" "es_snapshot_role" {
  name = "es-snapshot-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "es.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "es-snapshot-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["s3:ListBucket"]
          Effect   = "Allow"
          Resource = "arn:aws:s3:::${var.prefix}-s3-es-bkp"
        },
        {
          Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
          Effect   = "Allow"
          Resource = "arn:aws:s3:::${var.prefix}-s3-es-bkp/*"
        }
      ]
    })
  }

  tags = {
    Name  = "${var.prefix}-es-snapshot-role"
    Owner = var.owner
  }
}


resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "lambda-exec-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["ec2:DescribeNetworkInterfaces", "ec2:CreateNetworkInterface", "ec2:DeleteNetworkInterface", "ec2:DescribeInstances", "ec2:AttachNetworkInterface"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
          Effect   = "Allow"
          Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
          Action   = ["iam:PassRole"]
          Effect   = "Allow"
          Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.es_snapshot_role.name}"
        },
        {
          Action   = ["es:ESHttpPut"]
          Effect   = "Allow"
          Resource = "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.prefix}-elasticsearch/*"
        }
      ]
    })
  }

  tags = {
    Name  = "${var.prefix}-lambda-exec-role"
    Owner = var.owner
  }
}
