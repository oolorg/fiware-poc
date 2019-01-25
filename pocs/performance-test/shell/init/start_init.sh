#!/bin/bash

export TEST_HOME=/home/user098/fiware-poc

../logging/start_logging.sh

sleep 60

./01-create-service.sh

sleep 10

./02-create-device.sh 470

sleep 20

./03-create-subscription.sh

sleep 60

# ../logging/start_logging.sh
#
# sleep 60

mosquitto_pub -h localhost -u iota -P password -t /start -m 1
