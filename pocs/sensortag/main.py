from json import dumps
from pprint import pprint
from time import sleep

from bluepy.btle import BTLEException
from bluepy.sensortag import KeypressDelegate
from bluepy.sensortag import SensorTag
from paho.mqtt.client import Client, MQTTv311

HOST = 'fiware'
PORT = 1883
USERNAME = 'iota'
PASSWORD = 'password'

TOPIC1 = "/testapikey/SensorTag1/attrs"
TOPIC2 = "/testapikey/SensorTag2/attrs"


def sensor_enabler(tag):
    tag.humidity.enable()
    tag.barometer.enable()
    tag.accelerometer.enable()
    tag.magnetometer.enable()
    tag.gyroscope.enable()
    tag.battery.enable()
    tag.keypress.enable()
    tag.setDelegate(KeypressDelegate())
    if tag.lightmeter is not None:
        tag.lightmeter.enable()
    else:
        print("Warning: no lightmeter on SensorTag " + tag)


def read_sensor_data(tag):
    data = {}
    data.update({"humidity": tag.humidity.read()})
    data.update({"barometer": tag.barometer.read()})
    data.update({"accelerometer": tag.accelerometer.read()})
    data.update({"magnetometer": tag.magnetometer.read()})
    data.update({"gyroscope": tag.gyroscope.read()})
    data.update({"lightmeter": tag.lightmeter.read()})
    data.update({"battery": tag.battery.read()})

    return data


def main():

    client = Client(protocol=MQTTv311)
    client.username_pw_set(USERNAME, password=PASSWORD)
    client.connect(HOST, port=PORT, keepalive=60)

    host1 = "98:07:2D:35:7B:00"
    host2 = "98:07:2D:40:95:83"

    print("Connecting to SensorTags")
    tag1 = SensorTag(host1)
    tag2 = SensorTag(host2)

    sensor_enabler(tag1)
    sensor_enabler(tag2)

    sleep(1.0)

    try:
        while True:
            data1 = read_sensor_data(tag1)
            data2 = read_sensor_data(tag2)
            sleep(1.0)
            pprint({"SensorTag1": data1})
            pprint({"SensorTag2": data2})
            client.publish(TOPIC1, payload=dumps(data1))
            client.publish(TOPIC2, payload=dumps(data2))
            sleep(30)
    except KeyboardInterrupt:
        print("Disconnected to SensorTags")
        tag1.disconnect()
        tag2.disconnect()


if __name__ == '__main__':
    while True:
        try:
            main()
        except BTLEException as e:
            print(e)
