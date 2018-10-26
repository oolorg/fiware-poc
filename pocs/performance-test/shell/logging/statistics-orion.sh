#!/bin/bash

date >> statistics-orion.log
curl -sX GET 'http://localhost:1026/statistics' -H 'fiware-service:ool' -H 'fiware-servicepath:/'| python3 -m json.tool >> statistics-orion.log
echo "" >>statistics-orion.log
