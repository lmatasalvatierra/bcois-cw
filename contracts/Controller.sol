pragma solidity ^0.4.23;

import "./DougEnabled.sol";
import "./Doug.sol";

contract Controller is DougEnabled{
    modifier senderIsManager() {
        address _contractAddress = Doug(DOUG).getContract("coiManager");
        require (msg.sender == _contractAddress, "Sender is not the manager");
        _;
    }

    function obtainDBContract(bytes32 DB) internal view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(DB);
        require (_contractAddress != 0x0, "Database Contract has not been deployed");
        return _contractAddress;
    }
}
