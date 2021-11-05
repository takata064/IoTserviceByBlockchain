pragma solidity ^0.4.19;

contract DeviceArea {
    mapping(address => string) addrToAreaName;

    event setAreaNameEvent(string areaName);

    function areaRegister(string _areaName) public {
        addrToAreaName[msg.sender] = _areaName;
        setAreaNameEvent(_areaName);
    }

    function getAreaName(address _userAddr) public view returns (string) {
        require(keccak256(addrToAreaName[_userAddr]) != keccak256(""));
        return addrToAreaName[_userAddr];
    }
}
