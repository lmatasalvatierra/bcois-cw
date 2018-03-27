pragma solidity ^0.4.4;
import "./DougEnabled.sol";
import "./Doug.sol";
import "./DataHelper.sol";
import "./CoiDB.sol";

contract Coi is DougEnabled {
    modifier senderIsManager() {
        address _contractAddress = Doug(DOUG).getContract("coiManager");
        require (msg.sender == _contractAddress);
        _;
    }

    function createCoi(uint ownerId) senderIsManager public returns (uint result) {
        address coiDb = obtainDBContract("coiDB");
        result = CoiDB(coiDb).createCoi(ownerId);
        return result;
    }

    function getCoi(uint certificateNumber) senderIsManager public view
        returns(uint _certificateNumber, uint _ownerId)
    {
        address coiDb = obtainDBContract("coiDB");

        (_certificateNumber, _ownerId) = CoiDB(coiDb).getCoi(certificateNumber);
        return (_certificateNumber, _ownerId);
    }

    function obtainDBContract(bytes32 DB) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(DB);
        require (_contractAddress != 0x0);
        return _contractAddress;
    }
}
