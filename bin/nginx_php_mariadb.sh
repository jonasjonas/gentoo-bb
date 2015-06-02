#!/bin/bash

VHOST_BASE=test.void
ADMINER_URL=db.${VHOST_BASE}
PHPINFO_URL=phpinfo.${VHOST_BASE}

VHOST_URL=${VHOST_BASE},${ADMINER_URL},${PHPINFO_URL}

USER_UID=$(id -u $(whoami))
USER_GID=$(id -g $(whoami))

start () {
    LOCAL_WEB=${1}
    LOCAL_DB=${2}

    # mariadb
    docker run -d \
        --name www_mariadb \
        --hostname www_mariadb \
        -v ${LOCAL_DB}:/var/lib/mysql/ \
        gentoobb/mariadb

    MYSQL_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' www_mariadb`

    # redis
    docker run -d \
        --name www_redis \
        --hostname www_redus \
        gentoobb/redis

    REDIS_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' www_redis`

    # nginx php
    docker run -d \
        -e VIRTUAL_HOST="$VHOST_URL" \
        -e NG_TMPL_ADMINER_URL="$ADMINER_URL" \
        -e NG_TMPL_PHPINFO_URL="$PHPINFO_URL" \
        -e NGINX_UID="$USER_UID" \
        -e NGINX_GID="$USER_GID" \
        -p 80:80 \
        -p 443:443 \
        --link www_mariadb:db \
        --link www_redis:redis \
        --name www_php \
        --hostname www_php \
        -v ${LOCAL_WEB}:/var/www/localhost \
        depage/nginx-php

    NGINX_IP=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' www_php`

    echo -e "\nmysql:\t\t $MYSQL_IP:3306 login: root/root"
    echo -e "redis:\t\t http://$REDIS_IP/"
    echo -e "nginx:\t\t http://$NGINX_IP/"
    echo -e "vhost:\t\t http://$VHOST_BASE/"
    echo -e "adminer:\t http://$ADMINER_URL/adminer.php?server=db"
    echo -e "phpinfo:\t http://$PHPINFO_URL/"
}

stop () {
    echo "stopping container:"
    docker stop www_php
    docker stop www_redis
    docker stop www_mariadb
    echo "destroying container:"
    docker rm www_php
    docker rm www_redis
    docker rm www_mariadb
}

case "${1}" in
    start) start ${2} $3;;
    stop) stop;;
*) echo  "
Start or stop a simple nginx php5.6 mariadb webstack.

usage: ${0} start|stop [local_web_dir] [local_mysql_dir]";;
esac
