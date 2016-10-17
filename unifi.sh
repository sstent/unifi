#!/bin/bash
# description: Start Unify server
# chkconfig: 2345 99 01

#MEMORY="-Xmx256M"
UNIFI=/usr/lib/unifi
if [ ! -d $UNIFI ]; then
        echo "Unifi not installed in $UNIFI"
        exit 1
fi
cd $UNIFI
case "$1" in

        start)

                if [ ! -d logs ]; then
                    mkdir logs
                fi
                nohup java -Djava.net.preferIPv4Stack=true $MEMORY -jar lib/ace.jar start >logs/unifi.log 2>&1 &
                sleep 5
                ./$0 status
                tail -f logs/server.log
        ;;

        stop)

                java -jar lib/ace.jar stop
                sleep 5
                ./$0 status

        ;;

        status)
                if (ps -ef|grep "[l]ib/ace.jar" >/dev/null); then
                        echo "Unifi Controler running.."
                        exit 0
                else
                        echo "Unifi Controler stopped.."
                        exit 1
                fi

        ;;

        *)
                echo "Usage: $ME start|stop|status"
        ;;
esac
