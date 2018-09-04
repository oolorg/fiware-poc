#!/bin/bash

for container in `docker ps | grep pub.sh | awk '{print $1}'`;
do
    docker rm --force $container &
    echo "Remove "$container
done
