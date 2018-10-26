#!/bin/bash

./01-create-service.sh
./02-create-device.sh
./03-create-subscription.sh

../logging/start_logging.sh
