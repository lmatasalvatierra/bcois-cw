pragma solidity ^0.4.4;
import "./DougEnabled.sol";
import "./Doug.sol";
import "./DataHelper.sol";
import "./CarrierDB.sol";

contract Carrier is DougEnabled {
    function createCoi(
        bytes32 policyNumber,
        address carrier,
        address owner,
        bytes32 effectiveDate,
        bytes32 expirationDate
    )
        public returns (bool result)
    {
        address manager = Doug(DOUG).getContract("coiManager");
        require (msg.sender == manager);
        address carrierDb = Doug(DOUG).getContract("carrierDB");
        require (carrierDb != 0x0);
        result = CarrierDB(carrierDb).createCoi(policyNumber, carrier, owner, effectiveDate, expirationDate);
        return result;
    }

    function getCoi(bytes32 policyNumber) public view
        returns(address _carrier, address _owner, DataHelper.Stage _status, bytes32 _effectiveDate, bytes32 _expirationDate)
    {
        address manager = Doug(DOUG).getContract("coiManager");
        require (msg.sender == manager);
        address carrierDb = Doug(DOUG).getContract("carrierDB");
        require (carrierDb != 0x0);

        (_carrier, _owner, _status, _effectiveDate, _expirationDate) = CarrierDB(carrierDb).getCoi(policyNumber);
        return (_carrier, _owner, _status, _effectiveDate, _expirationDate);
    }

    function isCOIActive(bytes32 policyNumber) public view returns (bool result) {
        address manager = Doug(DOUG).getContract("coiManager");
        require (msg.sender == manager);
        address carrierDb = Doug(DOUG).getContract("carrierDB");
        require (carrierDb != 0x0);
        result = CarrierDB(carrierDb).isCOIActive(policyNumber);
        return result;
    }

    function cancelCOI(bytes32 policyNumber) public returns (bool result) {
        address manager = Doug(DOUG).getContract("coiManager");
        require (msg.sender == manager);
        address carrierDb = Doug(DOUG).getContract("carrierDB");
        require (carrierDb != 0x0);
        result = CarrierDB(carrierDb).cancelCOI(policyNumber);
        return result;
    }
}
