//const Temp = require('./contract_pi').Temp
const Temp = require('./contract_pi_mumbai').Temp
const CSV = require('./csv').CSVIO;
var sensorLib = require("node-dht-sensor");
const express = require('express')
var request = require('request');
const csv = new CSV()
const app = new express();
const temp = new Temp()
app.use(express.static(__dirname));

//httpで受付
//温度登録
app.get('/', async (req, res) => {
    let state = await temp.setTemp(req.query.tempdata)
    console.log(state)
})

//グラフ表示
app.get('/image', async (req, res) => {
    console.log("send image")
    res.sendFile(__dirname + '/graph.html');
})

app.listen(3000, () => {
    console.log('start')
})

//登録処理
const send = (tempdata) => {
    var options = {
        url: 'http://localhost:3000?tempdata=' + tempdata,
        method: 'GET'
    }
    request(options, function (error, response, body) { })
}

//温度を取得して、リクエスト送信
var sensor = {
    initialize: function () {
        return sensorLib.initialize(11, 17);
    },
    read: function () {
        var readout = sensorLib.read();
        var tempdata = readout.temperature;
        console.log('温度: ' + tempdata + '°C')
        csv.csvWirte(tempdata)
        send(tempdata)
        setTimeout(function () {
            sensor.read();
        }, 2000);
    }
};

if (sensor.initialize()) {
    sensor.read();
} else {
    console.warn('Failed to initialize sensor');
}
