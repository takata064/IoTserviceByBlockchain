let contract = null;
let account = null;

window.addEventListener('load', async function () {
    if (window.ethereum) {
        let instance = new Web3(window.ethereum);
        try {

            // アカウントへのアクセスを要求する
            await window.ethereum.enable();

            // MetaMaskのプロバイダの使用
            currentWeb3 = instance;

            // アカウントの取得
            const accounts = await currentWeb3.eth.getAccounts();
            account = accounts[0];

            // アカウントを画面表示
            document.getElementById('initialload').innerHTML = "送信元:" + account;
            console.log(account);

            //startApp();

        } catch (error) {
            // アクセスを拒否された時のアラートを表示
            alert(error);
        }
    }
});

async function startApp() {
    const contractAddr = "0x0Ebe738cFe873Ec7f5AFC5c4c231fD7a7cFb65AC";
    contract = new currentWeb3.eth.Contract(abi, contractAddr);

    var accountInterval = function () {
        if (web3.eth.accounts[0] !== account) {
            account = web3.eth.accounts[0];
        }
    };

    setInterval(accountInterval, 100);
}

function setAreaName(areaName) {
    $("#status").text("setting AreaName...");

    contract.methods.areaRegister(areaName)
        .send({ from: account })
        .on("recipt", function (recipt) {
            $("#status").text("Successfully set " + areaName + "!");
        })
        .on("error", function (error) {
            $("#txStatus").text(error);
        });
}

function getAreaName(userAddr) {
    $("#status").text("Checking...");

    contract.methods.getAreaName(userAddr)
        .call()
        .then(function (result) {
            $("#status").text("areaName : " + result);
        });
}

function setTemperatures(temperature, time) {
    $("#status").text("setting Temperature...");

    contract.methods.temperaturesRegister(temperature, time)
        .send({ from: account })
        .on("recipt", function (recipt) {
            $("#status").text("Successfully set " + temperature + " , " + time + "!");
        })
        .on("error", function (error) {
            $("#txStatus").text(error);
        });
}

function getTemperaturesById(id) {
    $("#status").text("Checking...");

    contract.methods.getTemperaturesById(id)
        .call()
        .then(function (result) {
            $("#status").text(result);
        });
}

function getTemperaturesByArea(name) {
    $("#status").text("Checking...");

    contract.methods.getTemperaturesByArea(name)
        .call()
        .then(function (result) {
            $("#status").text(result);
        });
}

function getTemperaturesByEOA(userAddr) {
    $("#status").text("Checking...");

    contract.methods.getTemperaturesByEOA(userAddr)
        .call()
        .then(function (result) {
            $("#status").text(result);
        });
}