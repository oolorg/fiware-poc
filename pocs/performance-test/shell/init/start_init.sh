#!/bin/bash

export TEST_HOME=/home/user098/fiware-poc

./01-create-service.sh

sleep 10

./02-create-device.sh 70

sleep 30

./03-create-subscription.sh

sleep 10

../logging/start_logging.sh

sleep 30

mosquitto_pub -h localhost -u iota -P password -t /start -m 1
