import os
import requests
from datetime import datetime, timedelta

# Elasticsearch Settings
elastic_hostname  = os.environ['ELASTIC_HOSTNAME']
elastic_username  = os.environ['ELASTIC_USERNAME']
elastic_password  = os.environ['ELASTIC_PASSWORD']
retention_days  = os.environ['RETENTION_DAYS']


def lambda_handler(event, context):
  
  # Delete ES Snapshot Backup for daily indices for Index template movie after retention period
  expirydate = (datetime.now() - timedelta(retention_days)).strftime('%Y-%m-%d')
  index_name = "movie-" + expirydate
  url     = elastic_hostname + "_snapshot/bkp-repo/" + index_name
  headers = {"Content-Type": "application/json", "kbn-xsrf": "true"}
  
  response = requests.delete(url, auth=(elastic_username, elastic_password), headers=headers)
  print(response.status_code)
  print(response.text)
