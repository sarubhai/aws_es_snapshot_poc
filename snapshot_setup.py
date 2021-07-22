import boto3
import os
import requests
from requests_aws4auth import AWS4Auth

# S3 Backup bucket
s3_bucket = os.environ['S3_BUCKET']
region    = os.environ['REGION']

# Elasticsearch Settings
elastic_hostname  = os.environ['ELASTIC_HOSTNAME']
elastic_username  = os.environ['ELASTIC_USERNAME']
elastic_password  = os.environ['ELASTIC_PASSWORD']
lambda_role_arn   = os.environ['LAMBDA_ROLE_ARN']
snapshot_role_arn = os.environ['SNAPSHOT_ROLE_ARN']

service     = 'es'
credentials = boto3.Session().get_credentials()
awsauth     = AWS4Auth(credentials.access_key, credentials.secret_key, region, service, session_token=credentials.token)


def lambda_handler(event, context):
  
  # Add Manage Snapshot Permission to Lamda Execution Role 
  url     = elastic_hostname + "/_opendistro/_security/api/rolesmapping/manage_snapshots"
  headers = {"Content-Type": "application/json", "kbn-xsrf": "true"}
  payload = {
    "backend_roles": [lambda_role_arn]
  }
  
  response = requests.put(url, auth=(elastic_username, elastic_password), json=payload, headers=headers)
  print(response.status_code)
  print(response.text)


  # Register S3 Snapshot Repository to Elasticsearch
  url     = elastic_hostname + "/_snapshot/bkp-repo"
  headers = {"Content-Type": "application/json"}
  payload = {
    "type": "s3",
    "settings": {
      "bucket": s3_bucket,
      "region": region,
      # "endpoint": "s3.amazonaws.com"
      "role_arn": snapshot_role_arn,
      "server_side_encryption": True
    }
  }
  
  response = requests.put(url, auth=awsauth, json=payload, headers=headers)
  print(response.status_code)
  print(response.text)
