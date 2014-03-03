#!/bin/bash

export PATH="/sbin:$PATH"

# usage: getssh.sh [container] [docker-network-device]

dockerdev=""

if [ $# == 0 ]; then
  container=${CONTAINER_ID}
elif [ $# == 1 ]; then
  container=$1
elif [ $# == 2 ]; then
    dockerdev = $2
fi

if [ x$dockerdev == x ]; then
    # assume there's just one
    dockerdev=$(ifconfig | grep docker | awk '{print $1}')
fi

echo NET: $dockerdev

ipaddr=$(ifconfig $dockerdev | grep inet | awk -F: '{print $2}' | awk '{print $1}')
echo IP: $ipaddr

port=$(docker port $container 22 | sed 's/.*:\(.*\)/\1/')
echo ssh -p $port $USER@$ipaddr
