# Name: s3.tf
# Owner: Saurav Mitra
# Description: This terraform config will create 1 S3 Bucket for ES Index Backup
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

# resource "aws_kms_key" "mykey" {
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 10
# }

resource "aws_s3_bucket" "s3_es_bkp" {
  bucket        = "${var.prefix}-s3-es-bkp"
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        # kms_master_key_id = aws_kms_key.mykey.arn
      }
    }
  }

  tags = {
    Name  = "${var.prefix}-s3-es-bkp"
    Owner = var.owner
  }
}

resource "aws_s3_bucket_public_access_block" "s3_es_bkp_block_public_access" {
  bucket                  = aws_s3_bucket.s3_es_bkp.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
