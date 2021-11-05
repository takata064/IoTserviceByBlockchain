// SPDX-License-Identifier: MIT

/*
 * @title DeviceAreaContract
 * @author Yuichi Takata <k19064kk@aitech.ac.jp>
 *
 * @dev このコントラクトはIoTデバイスの設置場所の登録、参照を行うことを目的としています。
 *
 */

pragma solidity ^0.8.7;

contract DeviceArea {
    mapping(address => string) addrToAreaName; //アドレスをキーとして、地域を参照

    event setAreaNameEvent(string indexed areaName, address indexed from); //地域名が登録された時に発火するイベント

    /*
     * @dev 文字列を比較して、同じかそうでないかを判別し判別します。
     * @param 比較対象の文字列を２つ引数として用意します。
     * @return 比較した結果をbool型で返します。
     */
    function isSameString(string memory _origin, string memory _target)
        internal
        pure
        returns (bool)
    {
        return
            keccak256(abi.encodePacked(_origin)) ==
            keccak256(abi.encodePacked(_target));
    }

    /*
     * @dev デバイスが設置されている地域名を登録します。登録した地域名は送信者のアドレスと紐付けられます。
     * @param 設置場所である地域名を引数として用意します。
     */
    function setAreaName(string calldata _areaName) public {
        require(!checkSetAreaName(msg.sender));
        addrToAreaName[msg.sender] = _areaName;
        emit setAreaNameEvent(_areaName, msg.sender);
    }

    /*
     * @dev 登録した地域名を変更します。
     * @param 変更したい地域名を引数として用意します。
     */
    function changeAreaName(string calldata _areaName) public {
        require(checkSetAreaName(msg.sender));
        addrToAreaName[msg.sender] = _areaName;
        emit setAreaNameEvent(_areaName, msg.sender);
    }

    /*
     * @dev 対象のアドレスに地域名が紐づけられているか確認します。
     * @param 対象のアドレスを引数とします。
     * @return 結果をbool型で返します。
     */
    function checkSetAreaName(address _userAddr)
        public
        view
        returns (bool res)
    {
        res = false;
        if (!isSameString(addrToAreaName[_userAddr], "")) {
            res = true;
        }
        return res;
    }

    /*
     * @dev 対象のアドレスに紐付けられている地域名を参照します。
     * @param たいしょうの対象のアドレスを引数とします。
     * @return stiring型の地域名を返します。
     */
    function getAreaName(address _userAddr)
        public
        view
        returns (string memory)
    {
        require(checkSetAreaName(_userAddr));
        return addrToAreaName[_userAddr];
    }
}
