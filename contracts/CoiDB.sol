pragma solidity ^0.4.4;
import "./DougEnabled.sol";
import "./Doug.sol";
import "./DataHelper.sol";

contract CoiDB is DougEnabled{
    struct CoI {
        address carrier;
        address owner;
        DataHelper.Stage status;
        uint effectiveDate;
        uint expirationDate;
    }

    mapping (bytes32 => CoI) public cois;

    modifier senderIsController() {
        address _contractAddress = Doug(DOUG).getContract("coi");
        require (msg.sender == _contractAddress);
        _;
    }

    function createCoi(
        bytes32 policyNumber,
        address _carrier,
        address _owner,
        uint _effectiveDate,
        uint _expirationDate
    )
        senderIsController public returns (bool result)
    {
        CoI memory coi;
        DataHelper.Stage _status = DataHelper.Stage.Active;
        coi = CoI(_carrier, _owner, _status, _effectiveDate, _expirationDate);
        cois[policyNumber] = coi;
        return true;
    }

    function getCoi(bytes32 policyNumber) senderIsController public view
        returns(address, address, DataHelper.Stage, uint, uint)
    {
        CoI memory coi;
        coi = cois[policyNumber];
        return (coi.carrier, coi.owner, coi.status, coi.effectiveDate, coi.expirationDate);
    }

    function updateStatus(bytes32 policyNumber, DataHelper.Stage _status) senderIsController public returns (bool result) {
        cois[policyNumber].status = _status;
        return true;
    }
}
