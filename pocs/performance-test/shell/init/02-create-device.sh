#!/bin/bash

for i in `seq 1 $1`
do
    curl -X POST 'http://localhost:4041/iot/devices' -H "Fiware-Service: ool" -H "Fiware-ServicePath: /" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d "{
        \"devices\": [
            {
                \"device_id\": \"device${i}\",
                \"entity_name\": \"sensor:device${i}\",
                \"entity_type\": \"sensor\",
                \"attributes\": [
                  {
                    \"object_id\":\"m\",
                    \"name\": \"messages\",
                    \"type\": \"text\"
                  }
                ],
                \"transport\": \"MQTT\"
            }
        ]
    }"
done
