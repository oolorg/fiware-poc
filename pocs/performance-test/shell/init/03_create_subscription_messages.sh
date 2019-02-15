#!/bin/bash

echo "Creating subscription."

curl -X POST 'http://localhost:1026/v2/subscriptions' -H "Fiware-Service: ool" -H "Fiware-ServicePath: /" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "description": "CYGNUS Subscription",
    "subject": {
        "entities": [
            {
                "idPattern": ".*"
            }
        ]
    },
    "notification": {
        "http": {
            "url": "http://cygnus-demo:5050/notify"
        },
        "attrs": [
                "messages"
        ],
        "attrsFormat": "legacy"
    },
    "expires": "2040-01-01T14:00:00.00Z"
}'

echo "Created subscription."
