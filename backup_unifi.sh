#!/bin/bash


#mongo logrotate
MONGOPID=$(ps -ef|grep [m]ongod|awk '{print $2}')
if [ -n "$MONGOPID" ]; then
	kill -SIGUSR1 $MONGOPID
fi 
#backup
cd /usr/lib/unifi1
bash ./unifi.sh stop
sleep 5
tar -czf backups/unifi_data.$(date '+%Y%m%d').tar.gz data >/dev/null
bash ./unifi.sh start

