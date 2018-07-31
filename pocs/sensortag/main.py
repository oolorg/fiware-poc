from json import dumps
from time import sleep

from bluepy.sensortag import KeypressDelegate
from bluepy.sensortag import SensorTag
from paho.mqtt.client import Client, MQTTv311

HOST = ''
PORT = 1883
USERNAME = ''
PASSWORD = ''

TOPIC1 = "/service/SensorTag1/attrs"
TOPIC2 = "/service/SensorTag2/attrs"


def main():

    client = Client(protocol=MQTTv311)
    client.username_pw_set(USERNAME, password=PASSWORD)
    client.connect(HOST, port=PORT, keepalive=60)

    host1 = "XX:XX:XX:XX:XX:XX"
    host2 = "YY:YY:YY:YY:YY:YY"

    print("Connecting to SensorTags")
    tag1 = SensorTag(host1)
    tag2 = SensorTag(host2)

    tag1.IRtemperature.enable()
    tag2.IRtemperature.enable()
    tag1.humidity.enable()
    tag2.humidity.enable()
    tag1.barometer.enable()
    tag2.barometer.enable()
    tag1.accelerometer.enable()
    tag2.accelerometer.enable()
    tag1.magnetometer.enable()
    tag2.magnetometer.enable()
    tag1.gyroscope.enable()
    tag2.gyroscope.enable()
    tag1.battery.enable()
    tag2.battery.enable()
    tag1.keypress.enable()
    tag1.setDelegate(KeypressDelegate())
    tag2.keypress.enable()
    tag2.setDelegate(KeypressDelegate())
    if tag1.lightmeter is not None:
        tag1.lightmeter.enable()
    else:
        print("Warning: no lightmeter on SensorTag1")
    if tag2.lightmeter is not None:
        tag2.lightmeter.enable()
    else:
        print("Warning: no lightmeter on SensorTag1")

    sleep(1.0)

    try:
        while True:
            data1 = {}
            data2 = {}
            data1.update({"temperature": tag1.IRtemperature.read()})
            data2.update({"temperature": tag2.IRtemperature.read()})
            data1.update({"humidity": tag1.humidity.read()})
            data2.update({"humidity": tag2.humidity.read()})
            data1.update({"barometer": tag1.barometer.read()})
            data2.update({"barometer": tag2.barometer.read()})
            data1.update({"accelerometer": tag1.accelerometer.read()})
            data2.update({"accelerometer": tag2.accelerometer.read()})
            data1.update({"magnetometer": tag1.magnetometer.read()})
            data2.update({"magnetometer": tag2.magnetometer.read()})
            data1.update({"gyroscope": tag1.gyroscope.read()})
            data2.update({"gyroscope": tag2.gyroscope.read()})
            data1.update({"lightmeter": tag1.lightmeter.read()})
            data2.update({"lightmeter": tag2.lightmeter.read()})
            data1.update({"battery": tag1.battery.read()})
            data2.update({"battery": tag2.battery.read()})
            tag1.waitForNotifications()
            tag2.waitForNotifications()
            sleep(1.0)
            client.publish(TOPIC1, payload=dumps(data1))
            client.publish(TOPIC2, payload=dumps(data2))
            sleep(30)
    except KeyboardInterrupt:
        print("Disconnected to SensorTags")
        tag1.disconnect()
        tag2.disconnect()


if __name__ == '__main__':
    main()
