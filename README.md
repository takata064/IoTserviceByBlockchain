# IoTserviceByBlockchain

## 概要
ラズベリーパイなどのIoTデバイスを用いて、取得したデータをブロックチェーンネットワーク上に保存できるシステムです。
また、登録したデータはブラウザなどから参照することができます。

## solidity
* デプロイ先 : ethereum(ropsten) or polygon network(mumbai)
* ファイル : IoTdataservice.sol
* コントラクトアドレス : 0xb0aDc62493E14Ef89C2991694b89144bBf84c1d4

## javascript
* 環境 : Chrome & matamask
* 動作 : INFURAなどのプロバイダでキーを取得し、index.htmlに書き込み。その後、webサーバ経由でindex.htmlを参照。

## nodejs
* デバイス : raspberrypi 4B(OS:Raspbian)
* 環境 : nodejs,matplot
* 動作 : index.jsをターミナル上で実行。
