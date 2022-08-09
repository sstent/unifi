FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive

ARG REPO

RUN mkdir -p /usr/lib/unifi/data /backups /logs

RUN apt-get -q update && apt-get -y upgrade && \
	apt-get install -y -q lsof anacron vim net-tools less gnupg2 apt-transport-https ca-certificates
# add unifi repo +keys
RUN deb http://www.ui.com/downloads/unifi/debian unifi-5.6 ubiquiti && \
    echo "deb http://www.ubnt.com/downloads/unifi/debian unifi-5.6 ubiquiti" >/etc/apt/sources.list.d/ubnt.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv C0A52C50 && \
	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6 && \
	echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" >/etc/apt/sources.list.d/mongodb-org-3.4.list

# update then install
COPY ["unifi_sysvinit_all.deb"]
RUN apt-get update -q -y && \
    # apt install -y ./unifi_sysvinit_all.deb
    apt-get install -y unifi 

#add scripts
COPY ["unifi.sh","backup_unifi.sh","restore_unifi.sh", "/usr/lib/unifi/"]
RUN echo "10 02 * * * root /usr/lib/unifi/backup_unifi.sh >/logs/backup.log 2>&1" >/etc/cron.d/unifi_backup

# https://community.ubnt.com/t5/UniFi-Wireless-Beta/IMPORTANT-Debian-Ubuntu-users-MUST-READ-Updated-06-21/td-p/1968253/jump-to/first-unread-message
RUN echo "JSVC_EXTRA_OPTS=\"\$JSVC_EXTRA_OPTS -Xss1280k\"" >>/etc/default/unifi

#redirect logs and backup
RUN rm -f /usr/lib/unifi/logs && ln -s /logs /usr/lib/unifi/logs
RUN rm -f /usr/lib/unifi/backups && ln -s /backups /usr/lib/unifi/backups

#define interface
VOLUME /usr/lib/unifi/data
VOLUME /backups /logs
EXPOSE  3748/udp 8443 8880 8080 27117

#Runtime Env
ENV PATH "$PATH:/usr/lib/unifi"
WORKDIR /usr/lib/unifi
CMD ["/usr/lib/unifi/unifi.sh", "start"]
