pragma solidity ^0.4.4;
import "./Doug.sol";
import "./DataHelper.sol";
import "./Carrier.sol";
import "./DougEnabled.sol";

contract COIManager is DougEnabled {
    address owner;

    function COIManager() public {
        owner = msg.sender;
    }

    function createCoi(
        bytes32 policyNumber,
        address carrier,
        bytes32 effectiveDate,
        bytes32 expirationDate
    )
        public returns (bool result)
    {
        address name_carrier = Doug(DOUG).getContract("carrier");
        if (name_carrier == 0x0 )
          return false;
        result = Carrier(name_carrier).createCoi(policyNumber, carrier, effectiveDate, expirationDate);
        return result;
    }

    function getCoi(bytes32 policyNumber) public view
        returns(address _carrier, DataHelper.Stage _status, bytes32 _effectiveDate, bytes32 _expirationDate)
    {
        address carrier = Doug(DOUG).getContract("carrier");
        if (carrier == 0x0 )
          return;
        (_carrier, _status, _effectiveDate, _expirationDate) = Carrier(carrier).getCoi(policyNumber);
        return (_carrier, _status, _effectiveDate, _expirationDate);
    }

    function isCOIActive(bytes32 policyNumber) public view returns (bool result) {
        address carrier = Doug(DOUG).getContract("carrier");
        if (carrier == 0x0 )
          return false;
        result = Carrier(carrier).isCOIActive(policyNumber);
        return result;
    }

    function cancelCOI(bytes32 policyNumber) public returns (bool result) {
      address carrier = Doug(DOUG).getContract("carrier");
      if (carrier == 0x0 )
        return false;
      result = Carrier(carrier).cancelCOI(policyNumber);
      return result;
    }
}
