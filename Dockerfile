FROM ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive

ARG REPO

RUN mkdir -p /usr/lib/unifi/data /backups /logs

RUN apt-get -q update && apt-get -y upgrade && \
	apt-get install -y -q lsof anacron vim net-tools less gnupg2 apt-transport-https ca-certificates


RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y \
    binutils \
    jsvc \
    logrotate \
    mongodb-server \
    openjdk-8-jre-headless \
    wget && \
    echo "**** cleanup ****" && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
  
RUN echo "**** install unifi ****" && \
  mkdir -p /app && \ 
  curl -o \
  /app/unifi.deb -L \
    "https://dl.ui.com/unifi/5.6.42/unifi_sysvinit_all.deb" && \ 
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*


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
