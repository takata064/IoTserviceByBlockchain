// SPDX-License-Identifier: MIT

/*
 * @title IoTDataManagerContract
 * @author Yuichi Takata <k19064kk@aitech.ac.jp>
 *
 * @dev このコントラクトはIoTデバイスから取得した値を時間、登録者、地名、データの種類と
 *      共にトランザクションとして保存する処理を行います。
 *
 */

pragma solidity ^0.8.7;

import "./userarea.sol";
import "./safemath.sol";
import "./time.sol";
import "./ownable.sol";

contract IoTDataManager is UserArea, Ownable, Time {
    using SafeMath for uint256;

    uint256 areaNameCount = 0;

    struct DataInfo {
        string dataName; //データの種類
        int64 value; //値
        string areaName; //取得した場所の地名
        uint256 timestamp; //時間
        address ownerAddr; //データ登録者
    }

    DataInfo[] public DataInfoList;

    mapping(uint256 => string) IdToAreaName;
    mapping(address => uint256) AddrToDataCount;
    mapping(address => uint256) addrToDataID;

    /*
     * @dev 初期化する時にデータの種類である、温度、湿度の２つを追加します。
     */
    constructor() {
        IdToAreaName[areaNameCount] = "temperature";
        areaNameCount = areaNameCount.add(1);
        IdToAreaName[areaNameCount] = "humidity";
        areaNameCount = areaNameCount.add(1);
    }

    /*
     * @dev データの種類を追加します。
     * @param データの種類の名前を引数にします。
     */
    function setDataName(string calldata _dataName) public onlyOwner {
        IdToAreaName[areaNameCount] = _dataName;
        areaNameCount = areaNameCount.add(1);
    }

    /*
     * @dev 誤って登録したデータの種類の名前を変更します。
     * @param データの種類のIDと変更後の名前を引数にします。
     */
    function changeDataName(uint256 _dataID, string calldata _dataName)
        public
        onlyOwner
    {
        require(_dataID < areaNameCount);
        IdToAreaName[_dataID] = _dataName;
    }

    /*
     * @dev 測定データをセットします。
     * @param 値、データのID、登録者のアドレスをセットします。
     */
    function SetDataInfo(
        int64 _value,
        uint256 _dataID,
        address _addr
    ) internal {
        DataInfoList.push(
            DataInfo(
                IdToAreaName[_dataID],
                _value,
                getAreaName(_addr),
                getTimestamp(),
                _addr
            )
        );

        addrToDataID[_addr] = _dataID;
        AddrToDataCount[_addr] = AddrToDataCount[_addr].add(1);
    }

    /*
     * @dev そのアドレスが登録したデータの一覧を返します。
     * @param 対象のアドレスを引数に持ちます。
     * @return 構造体の配列を返します。
     */
    function getDataInfoByAddr(address _addr)
        internal
        view
        returns (DataInfo[] memory resData)
    {
        require(AddrToDataCount[_addr] >= 1);

        resData = new DataInfo[](AddrToDataCount[_addr]);
        uint256 datacount = 0;

        for (uint256 i = 0; i < DataInfoList.length; i++) {
            if (DataInfoList[i].ownerAddr == _addr) {
                resData[datacount] = DataInfoList[i];
                datacount++;
            }
        }

        return resData;
    }

    /*
     * @dev 登録された全データを閲覧します。（オーナーのみ）
     * @return 構造体の配列を返します。
     */
    function getAllDataInfo()
        public
        view
        onlyOwner
        returns (DataInfo[] memory)
    {
        return DataInfoList;
    }
}
