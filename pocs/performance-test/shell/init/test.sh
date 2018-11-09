#!/bin/bash

echo "Creating devices"

for i in `seq -f %05g 11 80`
do
    curl -X POST 'http://localhost:4041/iot/devices' -H "Fiware-Service: ool" -H "Fiware-ServicePath: /" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d "{
        \"devices\": [
            {
                \"device_id\": \"vm1device${i}\",
                \"entity_name\": \"sensor:vm1device${i}\",
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

echo "Created devices"
