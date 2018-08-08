from datetime import datetime
from json import dumps
from time import sleep

from paho.mqtt.client import Client, MQTTv311
import RPi.GPIO as GPIO
import wiringpi as wp

import dht11

HOST = 'fiware'
PORT = 1883
USERNAME = 'iota'
PASSWORD = 'password'

TOPIC = "/apikey1/sensor01/attrs"

SPI_CH = 0
PIN_BASE = 64

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.cleanup()

instance = dht11.DHT11(pin=14)


def sensor_init():
    wp.mcp3002Setup(PIN_BASE, SPI_CH)


def read_odor():
    return wp.analogRead(PIN_BASE)


def read_dht11():
    values = 0
    while True:
        values = instance.read()
        if values.temperature is not 0 and values.humidity is not 0:
            break
        sleep(0.01)
    return values.temperature, values.humidity


def read_sensor_data():
    temp, hum = read_dht11()
    data = {}
    data.update({"odor": read_odor()})
    data.update({"temperature": temp})
    data.update({"humidity": hum})
    return data


def main():
    client = Client(protocol=MQTTv311)
    client.username_pw_set(USERNAME, password=PASSWORD)
    client.connect(HOST, port=PORT, keepalive=60)

    while True:
        data = read_sensor_data()
        print(data)
        client.publish(TOPIC, payload=dumps(data))
        sleep(5)


if __name__ == '__main__':
    sensor_init()
    main()
