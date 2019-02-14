#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

for container in $(docker ps -q); do
    iflink=`docker exec -it $container bash -c 'cat /sys/class/net/eth0/iflink'`
    iflink=`echo $iflink|tr -d '\r'`
    veth=`grep -l $iflink /sys/class/net/veth*/ifindex`
    veth=`echo $veth|sed -e 's;^.*net/\(.*\)/ifindex$;\1;'`
    echo $container:$veth >>  ${logpath}veth.log
    echo "" >>  ${logpath}veth.log
done

docker ps -a >> ${logpath}veth.log
