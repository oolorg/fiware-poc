/**************************************
 * Data request and parser. This may be part of a model in MVC
 */
function loadData(callback) {
    var loadLocalData = false,     //change this if you want to perform a request to a real instance of sth-comet
    //change the urlParams and headers if you want to query your own entity data.
        urlParams = {
            dateFrom: '',
            dateTo: '',
            lastN: 30
        },
        headers = {
            'Fiware-Service': 'myhome',
            'Fiware-ServicePath': '/environment'
            //'X-Auth-Token': 'XXXXXXX'
        };

    if (loadLocalData) {
        return callback(rawTemperatureSamples); //return samples from samples.js
    } else {

        return $.ajax({
            method: 'GET',
            //Change this URL if you want to use your own sth-comet
            url: 'http://172.16.254.11:8666/STH/v1/contextEntities/type/potSensor/id/RosesPot/attributes/humidity',
            data: urlParams,
            headers: headers,
            dataType: 'json',
            success: function(data) {
                return callback(data);
            }
        });
    }
}

function parseSamples(values) {
    return values.map(function(point) {
        return {
            x: new Date(point.recvTime),
            y: point.attrValue
        }
    });
}

/**
 * draw data. This may be part of a controller code in MVC
 */
function loadGraph(data) {

    nv.addGraph(function() {
        var chart = nv.models.lineChart();
        chart.margin({
            top: 50,
            right: 150,
            bottom: 50,
            left: 50
        });
        chart.xAxis
            //.tickFormat(d3.time.format('%x %X'));
            .ticks(0)
            .tickFormat(function(d) {
                return d3.time.format('%x %X')(new Date(d))
            })
            .rotateLabels(45);

        chart.yAxis
            .tickFormat(d3.format(',.2f'));

//        d3.select('#chart svg')
        d3.select('#chart svg')
            .datum(data)
            .transition().duration(0)
            .call(chart);

        nv.utils.windowResize(chart.update);

        return chart;
    });
}

function init() {

    return loadData(function(data) {
        var values = data.contextResponses[0].contextElement.attributes[0].values,
            attrName = data.contextResponses[0].contextElement.attributes[0].name,
            samples = [
                {
                    key: attrName,
                    values: parseSamples(values)
                }
            ];
        loadGraph(samples);
    });
}

//execute the main method
init();
