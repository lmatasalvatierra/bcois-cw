pragma solidity ^0.4.4;
import "./DougEnabled.sol";
import "./Doug.sol";
import "./DataHelper.sol";

contract CarrierDB is DougEnabled{
    struct CoI {
        address carrier;
        DataHelper.Stage status;
        bytes32 effectiveDate;
        bytes32 expirationDate;
    }

    mapping (bytes32 => CoI) public cois;

    function createCoi(
        bytes32 policyNumber,
        address _carrier,
        bytes32 _effectiveDate,
        bytes32 _expirationDate
    )
        public returns (bool result)
    {
        address name_carrier = Doug(DOUG).getContract("carrier");
        if (msg.sender != name_carrier) {
            return false;
        }
        CoI memory coi;
        DataHelper.Stage _status = DataHelper.Stage.Active;
        coi = CoI(_carrier, _status, _effectiveDate, _expirationDate);
        cois[policyNumber] = coi;
        return true;
    }

    function getCoi(bytes32 policyNumber) public view
        returns(address, DataHelper.Stage, bytes32, bytes32)
    {
        address name_carrier = Doug(DOUG).getContract("carrier");
        if (msg.sender != name_carrier) {
            return;
        }
        CoI memory coi;
        coi = cois[policyNumber];
        return (coi.carrier, coi.status, coi.effectiveDate, coi.expirationDate);
    }

    function isCOIActive(bytes32 policyNumber) public view returns (bool result) {
        address carrier = Doug(DOUG).getContract("carrier");
        if (msg.sender != carrier)
            return false;
        if (cois[policyNumber].status == DataHelper.Stage.Active) {
          return true;
        }
        return false;
    }

    function cancelCOI(bytes32 policyNumber) public returns (bool result) {
      address carrier = Doug(DOUG).getContract("carrier");
      if (msg.sender != carrier)
          return false;
      cois[policyNumber].status = DataHelper.Stage.Cancelled;
      return true;
    }
}
