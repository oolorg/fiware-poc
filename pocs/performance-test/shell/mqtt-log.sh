#!/bin/bash

mosquitto_sub -h localhost -p 1883 -u iota -P password -t /apikey/# > mqtt.log
