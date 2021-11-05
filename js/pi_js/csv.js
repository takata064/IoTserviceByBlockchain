const createCsvWriter = require('csv-writer').createObjectCsvWriter;
require('date-utils');

let path = "./sensor_data.csv"
let data = ""
let csvWriter = ""

class csvIO {
    constructor() {
        csvWriter = createCsvWriter({
            path: path,       // 保存する先のパス(すでにファイルがある場合は上書き保存)
            header: ['temp', 'time'],  // 出力する項目(ここにない項目はスキップされる)
            append: true
        });
    }

    csvWirte(tempdata) {
        let dt = new Date();
        let formatted = dt.toFormat("YYYY/MM/DD HH24:MI:SS");
        data = [
            { temp: tempdata, time: formatted }
        ];

        // 書き込み
        csvWriter.writeRecords(data)
            .then(() => {
                console.log('csv write done');
            });
    }
}

module.exports = {
    CSVIO: csvIO
}