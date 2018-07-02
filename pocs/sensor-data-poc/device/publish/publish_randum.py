#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (c) 2014 Roger Light <roger@atchoo.org>
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

# This shows an example of using the publish.multiple helper function.

import context  # Ensures paho is in PYTHONPATH
import paho.mqtt.publish as publish
import paho.mqtt.client as paho
import random

humidity_value = random.randrange(10,100,10)
happiness_value = "Not bat"

topic_value = "/test/sensor02/attrs"
payload_value = "{\"humidity\": \"%s\", \"happiness\": \"%s\"}" % (humidity_value,happiness_value)
qos_value = 0
retain_value = False
hostname_value = "172.16.254.26"
port_value = 1883
client_id_value = ""
keepalive_value = 60
will_value = None
auth_value =  {'username':"iota", 'password':"password"}
tls_value = None
protocol_value = paho.MQTTv311
transport_value = "tcp"


publish.single(topic_value, payload=payload_value, qos=qos_value,retain=retain_value, hostname=hostname_value, port=port_value, client_id=client_id_value, keepalive=keepalive_value, will=will_value,  auth = auth_value, tls=tls_value, protocol=protocol_value, transport=transport_value )
