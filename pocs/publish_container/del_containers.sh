#!/bin/bash

for container in `docker ps | grep pub.sh | awk '{print $10}'`;
do
    docker rm --force $container
    echo "Remove "$container
done
