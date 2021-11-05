// SPDX-License-Identifier: MIT

/*
 * @title IoTDataServiceContract
 * @author Yuichi Takata <k19064kk@aitech.ac.jp>
 *
 * @dev このコントラクトはIoTDataManagerを継承し、料金の支払いやデータの閲覧の制限
 *      を管理するためのコントラクトです。
 *
 */

pragma solidity ^0.8.7;

import "./IoTdatamanager.sol";

contract IoTDataService is IoTDataManager {
    address payable internal contractOwner;

    struct tradeInfo {
        address toAddr; //支払先
        address fromAddr; //支払い元
        uint256 limit; //期限
    }

    tradeInfo[] public tradeInfoList; //取引情報の管理用
    address[] public userlist; //ユーザ一覧の管理用

    /*
     * @dev システム提供者のアドレスをオーナーとして初期化します。
     */
    constructor() {
        contractOwner = payable(msg.sender);
    }

    /*
     * @dev ユーザーの初期情報を登録します。
     * @param 引数にアドレスに紐づける地名を用意します。
     */
    function setUser(string calldata _areaName) public {
        require(!checkSetAreaName(msg.sender));
        userlist.push(msg.sender);
        setAreaName(_areaName);
    }

    /*
     * @dev ユーザーの登録情報を確認します。
     */
    function checkUserInfo() public view returns (string memory areaName) {
        areaName = "";

        if (checkSetAreaName(msg.sender)) {
            areaName = getAreaName(msg.sender);
        }

        return areaName;
    }

    /*
     * @dev 登録されたユーザ情報と引数の値を元にデータを登録します。また、少額の手数料が発生します。
     * @param 値とデータIDを引数に持ちます。
     */
    function setData(int64 _value, uint256 _dataID) public payable {
        require(checkSetAreaName(msg.sender));
        require(msg.value == 1);
        SetDataInfo(_value, _dataID, msg.sender);
        contractOwner.transfer(1);
    }

    /*
     * @dev データを提供しているユーザのリストとデータ登録の登録数、主に登録しているデータの種類を返します。
     * @return アドレスの配列とuintの配列を配列を返します。
     */
    function getUserList()
        public
        view
        returns (
            address[] memory,
            uint256[] memory dataCount,
            string[] memory dataName
        )
    {
        dataCount = new uint256[](userlist.length);
        dataName = new string[](userlist.length);

        for (uint256 i = 0; i < userlist.length; i++) {
            dataCount[i] = AddrToDataCount[userlist[i]];
            dataName[i] = IdToAreaName[addrToDataID[userlist[i]]];
        }

        return (userlist, dataCount, dataName);
    }

    /*
     * @dev 送信先と送信元の情報を元に元に元取引履歴が存在するか、期限は有効かのデータを返します。
     * @param 比較対象のアドレスを２つ用意します。
     * @return bool型で取引履歴の存在可否と期限が有効かどうかを返します。
     */
    function checkTradeInfo(address _to, address _from)
        internal
        view
        returns (bool, bool)
    {
        bool flag = false;
        bool limitok = false;

        for (uint256 i = 0; i < tradeInfoList.length; i++) {
            if (
                tradeInfoList[i].toAddr == _to &&
                tradeInfoList[i].fromAddr == _from
            ) {
                flag = true;
                if (tradeInfoList[i].limit >= block.timestamp) {
                    limitok = true;
                }
            }
        }
        return (flag, limitok);
    }

    /*
     * @dev データ閲覧のための期限を延長します。
     * @param 対象のアドレスを２つ用意します。
     */
    function addlimit(address _to, address _from) internal {
        for (uint256 i = 0; i < tradeInfoList.length; i++) {
            if (
                tradeInfoList[i].toAddr == _to &&
                tradeInfoList[i].fromAddr == _from
            ) {
                tradeInfoList[i].limit = (block.timestamp + 5 minutes);
            }
        }
    }

    /*
     * @dev 宛先に送金をすることでデータの閲覧を可能にします。
     * @param 送信先のアドレスをアドレスを引数にします。
     */
    function sendMoney(address payable _to) public payable {
        uint256 amount = 1000;
        bool check;
        bool checklimit;
        (check, checklimit) = checkTradeInfo(_to, msg.sender);
        require(msg.value == amount + 1);
        require(!checklimit);

        if (!check) {
            tradeInfoList.push(
                tradeInfo(_to, msg.sender, (block.timestamp + 5 minutes))
            );

            _to.transfer(amount - 1);
            contractOwner.transfer(1);
        } else {
            _to.transfer(amount - 1);
            contractOwner.transfer(1);
            addlimit(_to, msg.sender);
        }
    }

    /*
     * @dev 閲覧可能であれば、そのアドレスで登録されたデータを返します。
     * @param 宛先のアドレスを引数にします。
     * @return 登録データの構造体を返します。
     */
    function viewData(address _to) public view returns (DataInfo[] memory) {
        bool checklimit;
        (, checklimit) = checkTradeInfo(_to, msg.sender);

        require(checklimit);

        return getDataInfoByAddr(_to);
    }
}
