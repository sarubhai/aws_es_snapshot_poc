import os
import requests
from datetime import datetime, timedelta

# Elasticsearch Settings
elastic_hostname  = os.environ['ELASTIC_HOSTNAME']
elastic_username  = os.environ['ELASTIC_USERNAME']
elastic_password  = os.environ['ELASTIC_PASSWORD']


def lambda_handler(event, context):
  
  # Create ES Snapshot Backup for daily indices for Index template movie
  yesterday = (datetime.now() - timedelta(1)).strftime('%Y-%m-%d')
  index_name = "movie-" + yesterday
  url     = elastic_hostname + "_snapshot/bkp-repo/" + index_name
  headers = {"Content-Type": "application/json", "kbn-xsrf": "true"}
  payload = {
    "indices": index_name,
    "ignore_unavailable": True,
    "include_global_state": False,
    "partial": False
  }
  
  response = requests.put(url, auth=(elastic_username, elastic_password), json=payload, headers=headers)
  print(response.status_code)
  print(response.text)
