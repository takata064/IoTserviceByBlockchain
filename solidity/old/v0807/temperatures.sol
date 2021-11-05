// SPDX-License-Identifier: MIT

/*
 * @title TemperaturesContract
 * @author Yuichi Takata <k19064kk@aitech.ac.jp>
 *
 * @dev このコントラクトは温度の登録、参照を目的としています。
 *      また、DeviceArea、Timeコントラクトを継承し、
 *      外部のライブラリとしてsafemath,Ownableを
 *      使用しています。
 *
 */

pragma solidity ^0.8.7;

import "./devicearea.sol";
import "./safemath.sol";
import "./time.sol";
import "./ownable.sol";

contract Temperatures is DeviceArea, Time, Ownable {
    using SafeMath for uint256;

    struct TemperaturesData {
        //温度構造体
        string areaName; //地域名
        uint256 timestamp; //タイムスタンプ
        int8 temperature; //温度
    }

    event addTempData(
        //温度構造体が登録された時に発火するイベント
        address indexed from,
        string areaName, //地域名
        uint256 timestamp, //タイムスタンプ
        int8 temperature, //温度
        uint256 id //登録ID（温度構造体の配列のインデックス）
    );

    mapping(uint256 => address) IdToAddr; //登録IDをキーとしてアドレス（登録者）を参照
    mapping(string => uint256) AreaDataCount; //その地域名で登録されたデータの数
    mapping(address => uint256) UsersDataCount; //そのアカウントが登録したデータの数

    TemperaturesData[] public TemperaturesDataList;

    /*
     * @dev 温度を登録します。情報の質を高めるために、地域名と時間も一緒に構造体として保存します。
     *      構造体は配列の後部に追加されます。
     * @param 登録する温度を引数として持ちます。
     */
    function temperaturesRegister(int8 _temperature) public {
        uint256 id;
        TemperaturesDataList.push(
            TemperaturesData(
                getAreaName(msg.sender),
                getTimestamp(),
                _temperature
            )
        );
        id = TemperaturesDataList.length - 1;

        IdToAddr[id] = msg.sender;
        UsersDataCount[msg.sender] = UsersDataCount[msg.sender].add(1);
        AreaDataCount[getAreaName(msg.sender)] = AreaDataCount[
            getAreaName(msg.sender)
        ].add(1);

        emit addTempData(
            msg.sender,
            getAreaName(msg.sender),
            getTimestamp(),
            _temperature,
            id
        );
    }

    /*
     * @dev 登録ID（インデックス）から情報を取得します。
     * @param uint型のIDを引数とします。
     * @return 検索結果として温度構造体を返します。
     */
    function getTemperaturesById(uint256 _id)
        public
        view
        returns (TemperaturesData memory)
    {
        require(TemperaturesDataList.length != 0);
        require(TemperaturesDataList.length >= _id);

        return TemperaturesDataList[_id];
    }

    /*
     * @dev 地域名から情報を取得します。
     * @param string型の地域名を引数とします。
     * @return 検索結果として温度構造体を返します。
     */
    function getTemperaturesByArea(string calldata _areaName)
        public
        view
        returns (TemperaturesData[] memory resData)
    {
        require(AreaDataCount[_areaName] >= 1);
        resData = new TemperaturesData[](AreaDataCount[_areaName]);

        uint256 dataCount = 0;
        for (uint256 i = 0; i < TemperaturesDataList.length; i++) {
            if (isSameString(_areaName, TemperaturesDataList[i].areaName)) {
                resData[dataCount] = TemperaturesDataList[i];
                dataCount = dataCount.add(1);
            }
        }
        return resData;
    }

    /*
     * @dev アドレス(EOA)から情報を取得します。
     * @param 対象のアドレスを引数とします。
     * @return 検索結果として温度構造体を返します。
     */
    function getTemperaturesByEOA(address _userId)
        public
        view
        returns (TemperaturesData[] memory resData)
    {
        require(UsersDataCount[_userId] >= 1);
        resData = new TemperaturesData[](UsersDataCount[_userId]);
        uint256 dataCount = 0;
        for (uint256 i = 0; i < TemperaturesDataList.length; i++) {
            if (IdToAddr[i] == _userId) {
                resData[dataCount] = TemperaturesDataList[i];
                dataCount = dataCount.add(1);
            }
        }
        return resData;
    }

    /*
     * @dev 全体でデータが幾つ登録されたかの確認をします。
     * @param 引数はありません。
     * @return データの個数をuint型で返します。
     */
    function getTemperaturesDataCount() public view returns (uint256) {
        return TemperaturesDataList.length;
    }

    /*
     * @dev 対象のアドレスが登録したデータのID一覧を確認できます。
     * @param 対象のアドレスを引数とします。
     * @return ID一覧を配列で返します。
     */
    function getSetDataIDsByEOA(address _address)
        public
        view
        returns (uint256[] memory res)
    {
        res = new uint256[](UsersDataCount[_address]);

        uint256 dataCount = 0;
        for (uint256 i = 0; i < TemperaturesDataList.length; i++) {
            if (IdToAddr[i] == _address) {
                res[dataCount] = i;
                dataCount = dataCount.add(1);
            }
        }

        return res;
    }

    /*
     * @dev 全ての登録データを確認できます。コントラクトの作成者が実行できます。
     * @param 引数はありません。
     * @return 温度構造体を配列で返します。
     */
    function getTemperaturesDataList()
        public
        view
        onlyOwner
        returns (TemperaturesData[] memory)
    {
        return TemperaturesDataList;
    }
}
