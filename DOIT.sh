#!/bin/bash

# must run as root; specify user to set up for

# pass in user as environement variable on first run; creates empty passwd
# entry; open up shadow file so that unix_chkpwd can read it (setgid
# doesn't work)

DOCKERENV_USER=$USER
DOCKERENV_HOST="$(hostname)"
DOCKERENV_HOSTIP="$(grep $DOCKERENV_HOST /etc/hosts | awk '{ print $1 }')"
DOCKERENV_AUTHKEYS=$(ssh-add -L)

echo "DOIT: $DOCKERENV_USER $DOCKERENV_HOST $DOCKERENV_HOSTIP"

docker build -t dougbo/docker-crd .
CONTAINER_ID=$(docker run \
    -e DOCKERENV_HOST="$DOCKERENV_HOST" \
    -e DOCKERENV_HOSTIP="$DOCKERENV_HOSTIP" \
    -e DOCKERENV_USER="$DOCKERENV_USER" \
    -e DOCKERENV_AUTHKEYS="$DOCKERENV_AUTHKEYS" \
    -d -P dougbo/docker-crd)
echo $CONTAINER_ID
