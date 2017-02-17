#!/bin/bash
VERSION=5.4.11
VMNAME=${1:-unifi5}
if [ -r Dockerfile.$VMNAME ]; then
	DOCKER_USER=${DOCKER_USER:-tommi2day}
	#build the container
	docker stop $VMNAME 
	docker rm $VMNAME 
	docker build -t $DOCKER_USER/$VMNAME:$VERSION -f Dockerfile.$VMNAME . |tee build.log 
	IMAGE=$(awk  '/^Successfully/ {print $3}' build.log)
	if [ -n "$IMAGE" ]; then
		docker tag $IMAGE $DOCKER_USER/$VMNAME:latest
	fi
else 
	echo "Usage: $0 VMNAME #Dockerfile.VMNAME must exists"
fi
