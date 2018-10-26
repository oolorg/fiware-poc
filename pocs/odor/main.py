import datetime
from datetime import timedelta, timezone
from json import dumps
from time import sleep

from paho.mqtt.client import Client, MQTTv311
import RPi.GPIO as GPIO
import wiringpi as wp

import dht11

JST = timezone(timedelta(hours=+9), 'JST')

HOST = 'fiware'
PORT = 1883
USERNAME = 'iota'
PASSWORD = 'password'

TOPIC = "/APIKEY_ABCD/MySensor01/attrs"

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
    aqi = read_odor()
    if aqi >= 0 and aqi <= 50:
        data.update({"aql": "Good"})
    elif aqi >= 51 and aqi <= 100:
        data.update({"aql": "Moderate"})
    elif aqi >= 101 and aqi <= 150:
        data.update({"aql": "Unhealthy for Sensitive Groups"})
    elif aqi >= 151 and aqi <= 200:
        data.update({"aql": "Unhealthy"})
    elif aqi >= 211 and aqi <= 300:
        data.update({"aql": "Very Unhealthy"})
    elif aqi >= 301:
        data.update({"aql": "Hazardous"})
    data.update({"aqi": aqi})
    data.update({"t": temp})
    data.update({"h": hum})
    return data


def on_disconnect(client, userdata, rc):
    if rc != 0:
        print("Unexpected MQTT disconnection. Will auto reconnect")


def main():
    client = Client(protocol=MQTTv311)
    client.username_pw_set(USERNAME, password=PASSWORD)
    client.on_disconnect = on_disconnect

    while True:
        data = read_sensor_data()
        data.update({"time": datetime.datetime.now(JST).isoformat()})
        print(data)
        try:
            client.connect(HOST, port=PORT, keepalive=60)
            client.publish(TOPIC, payload=dumps(data))
            client.disconnect()
        except ConnectionRefusedError as e:
            print(e)
        except OSError as e:
            print(e)

        sleep(30)


if __name__ == '__main__':
    sensor_init()
    main()
