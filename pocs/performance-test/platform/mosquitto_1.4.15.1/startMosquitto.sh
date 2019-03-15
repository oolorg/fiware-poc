#!/usr/bin/env bash

mosquitto_passwd -b /etc/mosquitto/pwfile ${IOT_USERNAME} ${IOTA_PASS}
/usr/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf
