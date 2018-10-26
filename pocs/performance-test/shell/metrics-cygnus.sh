#!/bin/bash

date >> metrics-cygnus.log
curl -sS localhost:41414/metrics | jq . >> metrics-cygnus.log
echo "source:`curl -sS localhost:41414/metrics | jq '.["SOURCE.http-source"]'.EventAcceptedCount`" >> metrics-cygnus.log
echo "channel:`curl -sS localhost:41414/metrics | jq '.["CHANNEL.mongo-channel"]'.EventTakeSuccessCount`" >> metrics-cygnus.log
echo "" >>metrics-cygnus.log
