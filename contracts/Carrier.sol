pragma solidity ^0.4.4;
import "./DougEnabled.sol";
import "./Doug.sol";
import "./DataHelper.sol";
import "./CarrierDB.sol";

contract Carrier is DougEnabled {
    function createCoi(
        bytes32 policyNumber,
        address carrier,
        bytes32 effectiveDate,
        bytes32 expirationDate
    )
        public returns (bool result)
    {
        address manager = Doug(DOUG).getContract("coiManager");
        if (msg.sender != manager)
            return false;
        address carrierDb = Doug(DOUG).getContract("carrierDB");
        if (carrierDb == 0x0 )
          return false;
        result = CarrierDB(carrierDb).createCoi(policyNumber, carrier, effectiveDate, expirationDate);
        return result;
    }

    function getCoi(bytes32 policyNumber) public view
        returns(address _carrier, DataHelper.Stage _status, bytes32 _effectiveDate, bytes32 _expirationDate)
    {
        address manager = Doug(DOUG).getContract("coiManager");
        if (msg.sender != manager)
            return;
        address carrierDb = Doug(DOUG).getContract("carrierDB");
        if (carrierDb == 0x0 )
            return;

        (_carrier, _status, _effectiveDate, _expirationDate) = CarrierDB(carrierDb).getCoi(policyNumber);
        return (_carrier, _status, _effectiveDate, _expirationDate);
    }

    function isCOIActive(bytes32 policyNumber) public view returns (bool result) {
        address manager = Doug(DOUG).getContract("coiManager");
        if (msg.sender != manager)
            return false;
        address carrierDb = Doug(DOUG).getContract("carrierDB");
        if (carrierDb == 0x0 )
          return false;
        result = CarrierDB(carrierDb).isCOIActive(policyNumber);
        return result;
    }

    function cancelCOI(bytes32 policyNumber) public returns (bool result) {
      address manager = Doug(DOUG).getContract("coiManager");
      if (msg.sender != manager)
          return false;
      address carrierDb = Doug(DOUG).getContract("carrierDB");
      if (carrierDb == 0x0 )
        return false;
      result = CarrierDB(carrierDb).cancelCOI(policyNumber);
      return result;
    }
}
