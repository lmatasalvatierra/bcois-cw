pragma solidity ^0.4.4;
import "./DougEnabled.sol";
import "./Doug.sol";
import "./DataHelper.sol";

contract CoiDB is DougEnabled{
    struct CoI {
        address carrier;
        address owner;
        DataHelper.Stage status;
        bytes32 effectiveDate;
        bytes32 expirationDate;
    }

    mapping (bytes32 => CoI) public cois;

    function createCoi(
        bytes32 policyNumber,
        address _carrier,
        address _owner,
        bytes32 _effectiveDate,
        bytes32 _expirationDate
    )
        public returns (bool result)
    {
        address addressCoi = Doug(DOUG).getContract("coi");
        require (msg.sender == addressCoi);
        CoI memory coi;
        DataHelper.Stage _status = DataHelper.Stage.Active;
        coi = CoI(_carrier, _owner, _status, _effectiveDate, _expirationDate);
        cois[policyNumber] = coi;
        return true;
    }

    function getCoi(bytes32 policyNumber) public view
        returns(address, address, DataHelper.Stage, bytes32, bytes32)
    {
        address addressCoi = Doug(DOUG).getContract("coi");
        require (msg.sender == addressCoi);
        CoI memory coi;
        coi = cois[policyNumber];
        return (coi.carrier, coi.owner, coi.status, coi.effectiveDate, coi.expirationDate);
    }

    function isCOIActive(bytes32 policyNumber) public view returns (bool result) {
        address addressCoi = Doug(DOUG).getContract("coi");
        require (msg.sender == addressCoi);
        if (cois[policyNumber].status == DataHelper.Stage.Active) {
          return true;
        }
        return false;
    }

    function cancelCOI(bytes32 policyNumber) public returns (bool result) {
        address addressCoi = Doug(DOUG).getContract("coi");
        require (msg.sender == addressCoi);
        cois[policyNumber].status = DataHelper.Stage.Cancelled;
        return true;
    }
}
