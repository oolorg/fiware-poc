#!/bin/bash

curl -X POST 'http://localhost:4041/iot/services' -H "Fiware-Service: ool" -H "Fiware-ServicePath: /" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "services": [
        {
            "resource": "",
            "apikey": "apikey",
            "type": "sensor"
        }
    ]
}'
