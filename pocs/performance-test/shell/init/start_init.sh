#!/bin/bash

export TEST_HOME=/home/user098/fiware-poc

NUMBER_OF_CONTAINERS=$1
SUBSCRIPTION_STATUS=$2

../logging/start_logging.sh

sleep 60

./01-create-service.sh

sleep 10

./02-create-device.sh ${NUMBER_OF_CONTAINERS}

sleep 20

if [ ${SUBSCRIPTION_STATUS} = "03-create-subscription-all.sh" ]; then
    ./03-create-subscription-all.sh
else
    ./03-create-subscription-messages.sh
fi

sleep 60

mosquitto_pub -h localhost -u iota -P password -t /start -m 1
