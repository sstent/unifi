#!/usr/bin/env bash
VMNAME=${2:-unifi5}
CMD=$1
DOCKER_SHARED=${DOCKER_SHARED:-$(pwd)}
DOCKER_USER=${DOCKER_USER:-tommi2day}
SHARED_DIR="${DOCKER_SHARED}/${VMNAME}-shared"
#debug
if [ -z "$DEBUG" ]; then
	RUN="-d "
else
	RUN="--rm=true -it --entrypoint bash "
fi
DOCKER="docker"

#datadir
if [ ! -d "${SHARED_DIR}" ]; then
	mkdir -p "${SHARED_DIR}"
fi
#stop and delete
RUNNING=$($DOCKER inspect --format="{{ .State.Running }}" $VMNAME 2> /dev/null)
if [ $? -eq 0 ]; then
	if [ "$RUNNING" == "true" ]; then
		$DOCKER stop $VMNAME >/dev/null 2>&1
	fi
	$DOCKER rm $VMNAME >/dev/null 2>&1
fi

if [ "$DEBUG" = "clean" ]; then
	#clean all if debug set to clean
	rm -Rf ${SHARED_DIR}
	$DOCKER volume rm  ${VMNAME}_data >/dev/null 2>&1
fi

#prepare shared dir
for d in backups logs data; do
	if [ ! -d $SHARED_DIR/$d ]; then
		mkdir -p $SHARED_DIR/$d
	fi
done


#check data volume and create a new one if needed
if [ "OSTYPE" = "msys" ]; then
	#on windows use a volume
	DATA=$($DOCKER docker inspect --format '{{ .Mountpoint }}' ${VMNAME}_data 2> /dev/null)
	if [ $? -ne 0 ]; then
		docker volume create --name ${VMNAME}_data --driver=local --
	fi
	DATA="${VMNAME}_data"
else
	DATA="${SHARED_DIR}/data"
fi


#run it
echo "	
$DOCKER run $RUN \
  -v $DATA:/usr/lib/unifi/data  \
  -v "${SHARED_DIR}/backups":/backups \
  -v "${SHARED_DIR}/logs":/logs \
  --hostname $VMNAME \
  --name ${VMNAME} \
  --restart=always \
  -p :8080:8080 \
  -p 8880:8880 \
  -p 8443:8443 \
  $DOCKER_USER/$VMNAME $1 " >starter
if [ "$OSTYPE" = "msys" ]; then
	mv starter starter.ps1
	powershell -File starter.ps1
else
	bash starter
fi

