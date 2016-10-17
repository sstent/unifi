# unifi5
Docker container for Ubiquiti Unifi5 Controler

this Docker container based on Ubuntu Trusty runs a Ubiquiti Unifi5 Controler. The Controler is a java app on top of MongoDB

[![Docker Pulls](https://img.shields.io/docker/pulls/tommi2day/unifi5.svg)](https://hub.docker.com/r/tommi2day/unifi5/)

### build
```sh
docker build -t tommi2day/unifi5 -f Dockerfile.unifi5 .
```
see also build_unifi.sh
### exposed Ports
```sh
# WebUI Inform mongodb  
EXPOSE  8443 8080 27117
```
### Volumes
```sh
VOLUME /usr/lib/unifi/data #Unifi config and data dir
VOLUME /backups /logs #logs and backup
```

### Environment variables used
```sh
None
```

### Run
Specify the  environment variable and a volume 
for the datafiles when launching a new container, e.g:

```sh
docker volume create --name unifi_data
docker run -d \
  -v unifi_data:/usr/lib/unifi/data  \
  -v /shared/unifi5/backups:/backups \
  -v /shared/unifi5/logs":/logs \
  --hostname unifi5 \
  --name unifi5 \
  -p 8080:8080 \
  -p 8443:8443 \
  -p 27117:27117 \
  tommi2day/unifi5
```
see run_unifi.sh for an example

### Addons
All Addons are in /usr/lib/unifi
####internal start/stop script
unifi.sh is a start/stop/status script. the start script calls finally a tail -f server.log to keep the container running
####Backup script
There is a cronjob in place calling backup_unifi.sh , which will trigger a logrotate for mongodb and afterwards
stop the Controler to tar the unifi data tree to /backups and restart finally. 
You can start it manually as well.
```
docker exec -ti unifi5 bash
./backup_unifi.sh
exit
```
To return to the console prompt press CTRL-C

####Restore script
for restoring a backup call/exec restore_unifi.sh [filename]. filename will be expected in /backups. Without filename the last backup
unifi_data.$(date '+%Y%m%d').tar.gz is assumed as default. 
Sample for the running container:
```
docker exec -ti unifi5 bash
./restore_unifi.sh /backups/unifi-backup.tar.gz
exit
```
This will stop and restart the unifi process. To return to the console prompt press CTRL-C
####Systemd service definition
unifi.service is a sample systemd start script for the already created container.
```
sudo cp unifi.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable unifi.service
sudo systemctl start unifi.service
```
 
see https://help.ubnt.com/hc/en-us/articles/220066768-UniFi-Debian-Ubuntu-APT-howto
