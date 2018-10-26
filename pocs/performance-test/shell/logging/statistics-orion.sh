#!/bin/bash

logpath=../../log/

date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}statistics-orion.log
curl -sX GET 'http://localhost:1026/statistics' -H 'fiware-service:ool' -H 'fiware-servicepath:/'| python3 -m json.tool >>  ${logpath}statistics-orion.log
echo "" >>  ${logpath}statistics-orion.log
