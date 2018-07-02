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


publish.single("/test/sensor02/attrs", payload="{\"humidity\": 77,\"happiness\": \"Not bad\"}", qos=0,retain=False, hostname="172.16.254.26", port=1883, client_id="", keepalive=60, will=None,  auth = {'username':"iota", 'password':"password"}, tls=None, protocol=paho.MQTTv311, transport="tcp" )
