# AWS Infra Demo Elasticsearch Domain:
Configure AWS Elasticsearch Domain using Terraform. This is part of the AWS demo infra setup for Enterprise Terraform workspace.

This is a PoC for Manual Snapshot of ES domain to S3 bucket.
Reference: [https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-managedomains-snapshots.html](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-managedomains-snapshots.html)

## Resources
- 1 Elasticsearch Domain
  - SAML enabled
- 1 S3 Bucket
- 1 Lambda Function to register the S3 snapshot config with ES

Addon:
- 1 Lambda Function along with Event Rule to schedule Daily Snapshot Backups
- 1 Lambda Function along with Event Rule to schedule Daily Snapshot Backup Deletion after 3 days (retention/expiry days)

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
PUT movie-2021-07-15/_doc/1
{ "movie_name": "Jurassic Park", "release_year": 1993, "watched_at" : "2021-07-15T12:00:00.000Z", "app_name" : "Netflix", "@timestamp" : "2021-07-15T12:00:00.000Z" }
PUT movie-2021-07-15/_doc/2
{ "movie_name": "Jumanji", "release_year": 1995, "watched_at" : "2021-07-15T16:00:00.000Z", "app_name" : "Netflix", "@timestamp" : "2021-07-15T16:00:00.000Z" }
PUT movie-2021-07-15/_doc/3
{ "movie_name": "Titanic", "release_year": 1997, "watched_at" : "2021-07-15T20:00:00.000Z", "app_name" : "Netflix", "@timestamp" : "2021-07-15T20:00:00.000Z" }

# View Index Documents 
GET movie-2021-07-15/_search

# Create a Snapshot of the Index
PUT _snapshot/bkp-repo/movie-2021-07-15
{
  "indices": "movie-2021-07-15",
  "ignore_unavailable": true,
  "include_global_state": false,
  "partial": false
}

# List all Manual Snapshots
GET _snapshot/bkp-repo/_all?pretty

# Delete sample Index
DELETE movie-2021-07-15

# Confirm Index deleted
GET movie-2021-07-15/_search

# Restore Index from Manual Snapshot
POST _snapshot/bkp-repo/movie-2021-07-15/_restore
{"indices": "movie-2021-07-15"}

# Confirm Index Restored
GET movie-2021-07-15/_search


# Delete Manual Snapshot
DELETE _snapshot/bkp-repo/movie-2021-07-15

# Confirm Manual Snapshots deleted
GET _snapshot/bkp-repo/_all?pretty

# Delete Manual Snapshot Config
# DELETE _snapshot/bkp-repo
```

Refer the file testing-DevTools.txt, for ISM policy based Snapshot Backup.