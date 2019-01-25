FROM fiware/cygnus-ngsi:1.9.0

ENV CYGNUS_MONITORING_TYPE "http"

COPY cygnus-entrypoint.sh / 
COPY agent.conf ${FLUME_HOME}/conf/ 
COPY agent.conf ${CYGNUS_HOME}/docker/cygnus-ngsi/agent.conf
COPY cartodb_keys.conf ${FLUME_HOME}/conf/

# Define the entry point
ENTRYPOINT ["/cygnus-entrypoint.sh"]

# Ports used by cygnus-ngsi
EXPOSE ${CYGNUS_SERVICE_PORT} ${CYGNUS_API_PORT}

