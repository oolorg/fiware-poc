#!/bin/bash

for container in `docker ps -a | grep pub.sh | awk '{print $1}'`;
do
    docker rm --force $container &
    echo "Remove "$container
done
