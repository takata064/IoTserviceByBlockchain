pragma solidity ^0.4.19;

import "./devicearea.sol";
import "./safemath.sol";
import "./strings.sol";

contract Temperatures is DeviceArea {
    using SafeMath for uint256;
    using strings for *;

    struct TemperaturesData {
        string areaName;
        string time;
        int16 temperature;
    }

    event addTempData(
        string areaName,
        string time,
        int16 temperature,
        uint256 id
    );

    mapping(uint256 => address) IdToAddr;
    mapping(string => uint256) AreaDataCount;
    mapping(address => uint256) UsersDataCount;

    TemperaturesData[] public TemperaturesDataList;

    function temperaturesRegister(int16 _temperature, string _time) public {
        uint256 id = TemperaturesDataList.push(
            TemperaturesData(getAreaName(msg.sender), _time, _temperature)
        ) - 1;
        IdToAddr[id] = msg.sender;
        AreaDataCount[addrToAreaName[msg.sender]] = AreaDataCount[
            addrToAreaName[msg.sender]
        ].add(1);
        UsersDataCount[msg.sender] = UsersDataCount[msg.sender].add(1);
        addTempData(addrToAreaName[msg.sender], _time, _temperature, id);
    }

    function getTemperaturesById(uint256 _id)
        public
        view
        returns (
            string resName,
            string resTime,
            int16 resTemperature
        )
    {
        require(TemperaturesDataList.length != 0);
        require(TemperaturesDataList.length >= _id);
        resName = TemperaturesDataList[_id].areaName;
        resTime = TemperaturesDataList[_id].time;
        resTemperature = TemperaturesDataList[_id].temperature;
        return (resName, resTime, resTemperature);
    }

    function getTemperaturesByArea(string _areaName)
        public
        view
        returns (
            string resName,
            string resTime,
            int16[] resTemperature
        )
    {
        require(AreaDataCount[_areaName] >= 1);
        resTemperature = new int16[](AreaDataCount[_areaName]);

        uint256 dataCount = 0;
        for (uint256 i = 0; i < TemperaturesDataList.length; i++) {
            if (
                keccak256(TemperaturesDataList[i].areaName) ==
                keccak256(_areaName)
            ) {
                resName = resName.toSlice().concat(
                    TemperaturesDataList[i].areaName.toSlice()
                );
                resName = resName.toSlice().concat(",".toSlice());
                resTime = resTime.toSlice().concat(
                    TemperaturesDataList[i].time.toSlice()
                );
                resTime = resTime.toSlice().concat(",".toSlice());
                resTemperature[dataCount] = TemperaturesDataList[i].temperature;
                dataCount = dataCount.add(1);
            }
        }
        return (resName, resTime, resTemperature);
    }

    function getTemperaturesByEOA(address _userId)
        public
        view
        returns (
            string resName,
            string resTime,
            int16[] resTemperature
        )
    {
        require(UsersDataCount[_userId] >= 1);
        resTemperature = new int16[](UsersDataCount[_userId]);
        uint256 dataCount = 0;
        for (uint256 i = 0; i < TemperaturesDataList.length; i++) {
            if (IdToAddr[i] == _userId) {
                resName = resName.toSlice().concat(
                    TemperaturesDataList[i].areaName.toSlice()
                );
                resName = resName.toSlice().concat(",".toSlice());
                resTime = resTime.toSlice().concat(
                    TemperaturesDataList[i].time.toSlice()
                );
                resTime = resTime.toSlice().concat(",".toSlice());
                resTemperature[dataCount] = TemperaturesDataList[i].temperature;
                dataCount = dataCount.add(1);
            }
        }
        return (resName, resTime, resTemperature);
    }
}
