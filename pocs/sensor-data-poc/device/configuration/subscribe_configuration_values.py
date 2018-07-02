#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (c) 2016 Roger Light <roger@atchoo.org>
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Distribution License v1.0
# which accompanies this distribution.
#
# The Eclipse Distribution License is available at
#   http://www.eclipse.org/org/documents/edl-v10.php.
#
# Contributors:
#    Roger Light - initial implementation

# This shows an example of using the subscribe.simple helper function.

import context  # Ensures paho is in PYTHONPATH
import paho.mqtt.subscribe as subscribe
import paho.mqtt.client as paho

topics = ['/test/sensor02/configuration/values']
# topics = ['#']
qos_value = 0
msg_count_value = 1
retained_value = False
hostname_value = "172.16.254.26"
port_value = 1883
client_id_value = ""
keepalive_value = 60
will_value = None
auth_value =  {'username':"iota", 'password':"password"}
tls_value = None
protocol_value = paho.MQTTv311
transport_value = "tcp"
clean_session_value = True

while True:
    m = subscribe.simple(topics, qos_value, msg_count_value, retained_value, hostname_value, port_value, client_id_value, keepalive_value, will_value, auth_value, tls_value, protocol_value, transport_value, clean_session_value)
    print(m.topic)
    print(m.payload)


