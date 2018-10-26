#!/bin/bash

curl -sX GET 'http://localhost:1026/v2/subscriptions' -H 'fiware-service:ool' -H 'fiware-servicepath:/' | python3 -m json.tool >> subscription-orion.log
echo "" >>subscription-orion.log
