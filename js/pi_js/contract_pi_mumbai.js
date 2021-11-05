const Web3 = require('web3')
const Tx = require('ethereumjs-tx').Transaction
const { performance } = require('perf_hooks')
const Common = require('@ethereumjs/common').COMMON

let web3 = ""
let account = ""
let privateKey = ""
let contractAddress = ""
let contract = ""
let trigger = ""

class temperatures_mumbai {

    constructor() {

        //取得したAPIキー（INFURA KEYS）を設定する
        const provider = new Web3.providers.HttpProvider('https://speedy-nodes-nyc.moralis.io/adf63353063b40c1220bd94c/polygon/mumbai')
        web3 = new Web3(provider)

        //MetaMaskのアカウントとその秘密鍵
        account = 'YOUR ADDRESS'
        privateKey = Buffer.from('YOUR PRIVATE KEY', 'hex')

        //デプロイしたコントラクトのアドレス
        contractAddress = '0xd581a9B8eB31AA92362Ddf8e6D04BB24BD9bd9Fb'

        //ABI情報
        const TEMP = require('./temp.json')
        const abi = TEMP.abi

        console.log('setteing abi....')

        //コントラクト設定
        contract = new web3.eth.Contract(abi, contractAddress)
        trigger = true

    }

    async setTemp(temp) {
        if (trigger == true) {
            trigger = false
            //スマコン関数に引数を設定
            console.log('setting func...');
            const contractFunction = contract.methods.temperaturesRegister(temp)
            const functionAbi = contractFunction.encodeABI()

            const startTime = performance.now()

            console.log('get nonce...');

            let nonce = await web3.eth.getTransactionCount(account);
            console.log(nonce)

            console.log('setting params');

            //パラメータの設定
            const txParams = {
                nonce: web3.utils.toHex(nonce),
                gasPrice: web3.utils.toHex(web3.utils.toWei('20', 'gwei')),
                gasLimit: web3.utils.toHex(210000),
                from: account,
                to: contractAddress,
                data: functionAbi,
                chainId: 80001
            };

            //署名

            const common = Common.custom('polygon-mumbai')

            const tx = new Tx(txParams, { common })
            tx.sign(privateKey)

            console.log('sign transaction....')

            const serializedTx = tx.serialize()

            console.log('send transaction....')

            //関数の実行

            web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'))
                .on('receipt', receipt => {
                    console.log(receipt)
                    const endTime = performance.now();
                    console.log(endTime - startTime);
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

    async getTempByID(id) {
        await contract.methods.getTemperaturesById(id).call()
            .then(res => console.log(res))
    }
}

module.exports = {
    Temp: temperatures_mumbai
}
