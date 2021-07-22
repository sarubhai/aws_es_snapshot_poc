# Name: main.tf
# Owner: Saurav Mitra
# Description: This terraform config will create 1 Elasticsearch Domain resource
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticsearch_domain

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# Need only once in AWS Account during 1st Elastic domain creation
# resource "aws_iam_service_linked_role" "es_role" {
#   aws_service_name = "es.amazonaws.com"
# }

# Create Elasticsearch Domain
resource "aws_elasticsearch_domain" "es_domain" {
  domain_name           = "${var.prefix}-elasticsearch"
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    zone_awareness_enabled   = true
    instance_type            = var.datanode_instance_type
    instance_count           = var.datanodes_count
    dedicated_master_enabled = true
    dedicated_master_type    = var.masternode_instance_type
    dedicated_master_count   = var.masternodes_count

    zone_awareness_config {
      availability_zone_count = length(data.terraform_remote_state.vpc.outputs.private_subnet_id)
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.ebs_volume_size_datanodes
    volume_type = var.ebs_volume_type
    # iops        = var.iops
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  vpc_options {
    subnet_ids         = data.terraform_remote_state.vpc.outputs.private_subnet_id
    security_group_ids = [aws_security_group.elastic_sg.id]
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-0-2019-07"
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  tags = {
    Name  = "${var.prefix}-elasticsearch"
    Owner = var.owner
  }

  # The ServiceRole is required before elasticsearch_domain resource can be created  
  # depends_on = [aws_iam_service_linked_role.es_role]
}

# Create Elasticsearch Domain Policy
resource "aws_elasticsearch_domain_policy" "access_policy" {
  domain_name = aws_elasticsearch_domain.es_domain.domain_name

  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:ESHttp*",
            "Principal": {
                "AWS": "*"
            },
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.prefix}-elasticsearch/*"
        }
    ]
}
POLICIES
}

# Add SAML Integration for Kibana
resource "aws_elasticsearch_domain_saml_options" "example" {
  domain_name = aws_elasticsearch_domain.es_domain.domain_name

  saml_options {
    enabled = true

    idp {
      entity_id        = var.saml_entity_id
      metadata_content = var.saml_metadata_xml
    }

    master_user_name        = var.saml_master_user_name
    master_backend_role     = var.saml_master_backend_role
    subject_key             = ""
    roles_key               = "Roles"
    session_timeout_minutes = 60
  }
}
