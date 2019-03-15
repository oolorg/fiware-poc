/*
 * Copyright 2015 Telefonica Investigación y Desarrollo, S.A.U
 *
 * This file is part of iotagent-json
 *
 * iotagent-json is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * iotagent-json is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public
 * License along with iotagent-json.
 * If not, seehttp://www.gnu.org/licenses/.
 *
 * For those usages not covered by the GNU Affero General Public License
 * please contact with::[contacto@tid.es]
 */
var config = {};

config.mqtt = {
    host: 'mosquitto-demo',
    port: 1883,
    thinkingThingsPlugin: true
};

config.iota = {
    logLevel: 'INFO',
    timestamp: true,
    contextBroker: {
        host: 'orion-demo',
        port: '1026'
    },
    server: {
        port: 4041
    },
    deviceRegistry: {
        type: 'mongodb'
    },
    mongodb: {
        host: 'mongodb-idas-demo',
        port: '27017',
        db: 'iotagentjson'
    },
    types: {},
    service: 'howtoService',
    subservice: '/howto',
    providerUrl: 'http://idas-demo:4041',
    deviceRegistrationDuration: 'P1M',
    defaultType: 'Thing',
    defaultResource: ''
};

config.configRetrieval = true;
config.defaultKey = '1234';
config.defaultTransport = 'MQTT';

module.exports = config;
