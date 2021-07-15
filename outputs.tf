# Name: outputs.tf
# Owner: Saurav Mitra
# Description: Outputs the Elasticsearch Domain ARN & Endpoints
# https://www.terraform.io/docs/configuration/outputs.html

output "elastic_arn" {
  value       = aws_elasticsearch_domain.es_domain.arn
  description = "Elasticsearch Domain ARN."
}

output "elastic_endpoint" {
  value       = aws_elasticsearch_domain.es_domain.endpoint
  description = "Elasticsearch Domain Endpoint."
}

output "kibana_endpoint" {
  value       = aws_elasticsearch_domain.es_domain.kibana_endpoint
  description = "Kibana Endpoint."
}
