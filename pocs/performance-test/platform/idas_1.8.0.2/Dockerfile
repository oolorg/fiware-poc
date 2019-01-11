
FROM fiware/iotagent-json:1.8.0

WORKDIR /opt/iotajson

COPY idas_1.8.0.2/config.js /opt/iotajson/config.js

ENTRYPOINT node --max_old_space_size=8192 bin/iotagent-json config.js

