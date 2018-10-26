from json import dumps
from pprint import pprint
from time import sleep
from urllib import parse

from bluepy.btle import BTLEException
from bluepy.sensortag import KeypressDelegate
from bluepy.sensortag import SensorTag
from paho.mqtt.client import Client, MQTTv311

HOST = 'fiware'
PORT = 1883
USERNAME = 'iota'
PASSWORD = 'password'

TOPIC1 = "/APIKEY_DCBA/SensorTag-01/attrs"
TOPIC2 = "/APIKEY_DCBA/SensorTag-02/attrs"


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
    data = "temperature=%f" % tag.humidity.read()[0] + \
           ";humidity=%f" % tag.humidity.read()[1] + \
           ";barometer=%f,%f" % tag.barometer.read() + \
           ";accelerometer=%f,%f,%f" % tag.accelerometer.read() + \
           ";magnetometer=%f,%f,%f" % tag.magnetometer.read() + \
           ";gyroscope=%f,%f,%f" % tag.gyroscope.read() + \
           ";lightmeter=%d" % tag.lightmeter.read()

    return {"bl": tag.battery.read(), "v": parse.quote(data)}


def main():

    client = Client(protocol=MQTTv311)
    client.username_pw_set(USERNAME, password=PASSWORD)

    host1 = "98:07:2D:40:95:83"
    host2 = "98:07:2D:35:7B:00"

    print("Connecting to SensorTags")
    tag1 = SensorTag(host1)
    #tag2 = SensorTag(host2)

    sensor_enabler(tag1)
    #sensor_enabler(tag2)

    sleep(1.0)

    try:
        while True:
            data1 = read_sensor_data(tag1)
            #data2 = read_sensor_data(tag2)
            sleep(1.0)
            pprint({"SensorTag1": data1})
            #pprint({"SensorTag2": data2})
            client.connect(HOST, port=PORT, keepalive=60)
            client.publish(TOPIC1, payload=dumps(data1))
            #client.publish(TOPIC2, payload=dumps(data2))
            client.disconnect()
            sleep(30)
    except KeyboardInterrupt:
        print("Disconnected to SensorTags")
        tag1.disconnect()
        #tag2.disconnect()


if __name__ == '__main__':
    while True:
        try:
            main()
        except BTLEException as e:
            print(e)
