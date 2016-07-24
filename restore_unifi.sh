#!/bin/bash

cd /usr/lib/unifi
DATE=$(date '+%Y%m%d')
bash ./unifi.sh stop 
sleep 5
FILE=${1:-unifi_data.$DATE.tar.gz}
if [ -r /backups/$FILE ]; then
  tar -czf /backups/unifi_data_before_restore.$(date '+%Y%m%d_%H%M%S').tar.gz data/
  rm -rf data/*
  tar -xzf /backups/$FILE data/
else 
  echo "Backup /backups/$FILE not readable"
fi
bash ./unifi.sh start

