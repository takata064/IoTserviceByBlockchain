// SPDX-License-Identifier: MIT

/*
 * @title TimeContract
 * @author Yuichi Takata <k19064kk@aitech.ac.jp>
 *
 * @dev このコントラクトは現在時間の取得など、時間の取得を目的としています。
 *
 */

pragma solidity ^0.8.7;

contract Time {
    /*
     * @dev UNIXタイムスタンプを取得します。
     * @param 引数はありません。
     * @return uint256型のタイムスタンプを返します。
     */
    function getTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }
}
