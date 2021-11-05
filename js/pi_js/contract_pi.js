const Web3 = require('web3')
const Tx = require('ethereumjs-tx').Transaction
const { performance } = require('perf_hooks')

let infuraKey = ""
let web3 = ""
let account = ""
let privateKey = ""
let contractAddress = ""
let contract = ""
let trigger = ""

class temperatures {

    constructor() {
        //プロバイダを設定する
        const provider = new Web3.providers.HttpProvider('https://speedy-nodes-nyc.moralis.io/adf63353063b40c1220bd94c/eth/ropsten')
        web3 = new Web3(provider)

        //MetaMaskのアカウントとその秘密鍵
        account = 'YOUR ADDRESS'
        privateKey = Buffer.from('YOUR PRIVATE KEY', 'hex')

        //デプロイしたコントラクトのアドレス
        contractAddress = '0xb0aDc62493E14Ef89C2991694b89144bBf84c1d4'

        //ABI情報
        const TEMP = require('./abi.json')
        const abi = TEMP.abi

        console.log('setteing abi....')

        //コントラクト設定
        contract = new web3.eth.Contract(abi, contractAddress)
        trigger = true

        console.log('setteing function....')

    }

    async setTemp(temp) {
        if (trigger == true) {
            trigger = false
            //スマコン関数に引数を設定
            console.log('setting func...');
            const contractFunction = contract.methods.setData(temp, 0)
            const functionAbi = contractFunction.encodeABI()

            const startTime = performance.now()

            console.log('get nonce...');

            let nonce = await web3.eth.getTransactionCount(account);

            //パラメータの設定
            const txParams = {
                nonce: web3.utils.toHex(nonce),
                gasPrice: web3.utils.toHex(web3.utils.toWei('4', 'gwei')),
                gasLimit: web3.utils.toHex(210000),
                from: account,
                to: contractAddress,
                data: functionAbi,
                value: "0x01"
            };

            console.log('set params...');

            //署名
            const tx = new Tx(txParams, { 'chain': 'ropsten' })
            tx.sign(privateKey)

            console.log('sign transaction....')

            const serializedTx = tx.serialize()

            //関数の実行
            web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'))
                .on('receipt', receipt => {
                    console.log(receipt)
                    const endTime = performance.now();
                    console.log("所要時間:" + endTime - startTime);
                    trigger = true
                })
                .on('error', error => {
                    console.log(error)
                    trigger = true
                })

            return 'send'
        } else {
            //receiptが帰ってくるまでは実行しない
            return 'busy'
        }

    }
}

module.exports = {
    Temp: temperatures
}