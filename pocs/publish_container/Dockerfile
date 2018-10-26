FROM python:3.6-alpine

ARG HOST
ARG USERNAME
ARG PASSWORD
ARG APIKEY
ARG PUB_INTERVAL
ARG DEVICE_ID
ENV HOST ${HOST:-localhost}
ENV USERNAME ${USERNAME:-iota}
ENV PASSWORD ${PASSWORD:-password}
ENV APIKEY ${APIKEY:-apikey}
ENV PUB_INTERVAL ${PUB_INTERVAL:-5}
ENV DEVICE_ID ${DEVICE_ID:-device00}

COPY dummy_device_app.py /home/dummy_device_app.py

RUN pip install paho-mqtt

CMD ["python", "-u", "/home/dummy_device_app.py"]
