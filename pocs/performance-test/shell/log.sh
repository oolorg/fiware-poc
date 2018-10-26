#!/bin/bash


for i in `docker ps --format '{{.Names}}'`
do
   cp -p `sudo docker inspect ${i} | grep LogPath | cut -d "\"" -f 4` ./${i}.log

done
