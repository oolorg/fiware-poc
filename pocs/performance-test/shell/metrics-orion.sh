#!/bin/bash

date >> metrics-orion.log
echo "out:`curl -sS localhost:1026/admin/metrics | jq '.services.ool.subservs."root-subserv".outgoingTransactions'`" >> metrics-orion.log
echo "in:`curl -sS localhost:1026/admin/metrics | jq '.services.ool.subservs."root-subserv".incomingTransactions'`" >> metrics-orion.log
echo "" >>metrics-orion.log
