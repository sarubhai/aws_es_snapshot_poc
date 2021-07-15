# AWS Infra Demo Elasticsearch Domain:
Configure AWS Elasticsearch Domain using Terraform. This is part of the AWS demo infra setup for Enterprise Terraform workspace.

This is a PoC for Manual Snapshot of ES domain to S3 bucket.
Reference: [https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-managedomains-snapshots.html](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-managedomains-snapshots.html)

## Resources
- 1 Elasticsearch Domain
  - SAML enabled
- 1 S3 Bucket
- 1 Lambda Function to register the S3 snapshot config with ES

## Backup/Restore
- Login to Kibana Dev Tools
```
# Get List of Snapshot Configs
GET _snapshot
# Check if Automated Snapshot is in Progress
GET _snapshot/_status

# Get Manual Snapshot Config
GET _snapshot/bkp-repo
# Check if Manual Snapshot is in Progress
GET _snapshot/bkp-repo/_status


# Create sample Index/Documents
PUT movies-2021-07-15/_doc/1
{ "title": "A Silent Voice", "genre": ["Animation", "Anime"] }
PUT movies-2021-07-15/_doc/2
{ "title": "Intersteller", "genre": ["Adventure", "SciFi"] }
PUT movies-2021-07-15/_doc/3
{ "title": "Salt", "genre": ["Action", "Mystery"] }

# View Index Documents 
GET movies-2021-07-15/_search

# Create a Snapshot of the Index
PUT _snapshot/bkp-repo/movies-2021-07-15
{
  "indices": "movies-2021-07-15",
  "ignore_unavailable": true,
  "include_global_state": false,
  "partial": false
}

# List all Manual Snapshots
GET _snapshot/bkp-repo/_all?pretty

# Delete sample Index
DELETE movies-2021-07-15

# Confirm Index deleted
GET movies-2021-07-15/_search

# Restore Index from Manual Snapshot
POST _snapshot/bkp-repo/movies-2021-07-15/_restore
{"indices": "movies-2021-07-15"}

# Confirm Index Restored
GET movies-2021-07-15/_search


# Delete Manual Snapshot
DELETE _snapshot/bkp-repo/movies-2021-07-15

# Confirm Manual Snapshots deleted
GET _snapshot/bkp-repo/_all?pretty

# Delete Manual Snapshot Config
# DELETE _snapshot/bkp-repo
```
