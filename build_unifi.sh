#!/bin/bash

VERS=5.0
VMNAME=${1:-unifi}
if [ -r Dockerfile.$VMNAME ]; then
DOCKER_USER=${DOCKER_USER:-tommi2day}
#build the container
docker stop $VMNAME 
docker rm $VMNAME 
docker build -t $DOCKER_USER/$VMNAME:$VERS -f Dockerfile.$VMNAME .
else 
	echo "Usage: $0 VMNAME #Dockerfile.VMNAME must exists"
fi
