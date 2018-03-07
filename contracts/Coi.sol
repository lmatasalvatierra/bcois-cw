pragma solidity ^0.4.4;
import "./DougEnabled.sol";
import "./Doug.sol";
import "./DataHelper.sol";
import "./CoiDB.sol";

contract Coi is DougEnabled {
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
        address coiDb = Doug(DOUG).getContract("coiDB");
        require (coiDb != 0x0);
        result = CoiDB(coiDb).createCoi(policyNumber, carrier, owner, effectiveDate, expirationDate);
        return result;
    }

    function getCoi(bytes32 policyNumber) public view
        returns(address _carrier, address _owner, DataHelper.Stage _status, bytes32 _effectiveDate, bytes32 _expirationDate)
    {
        address manager = Doug(DOUG).getContract("coiManager");
        require (msg.sender == manager);
        address coiDb = Doug(DOUG).getContract("coiDB");
        require (coiDb != 0x0);

        (_carrier, _owner, _status, _effectiveDate, _expirationDate) = CoiDB(coiDb).getCoi(policyNumber);
        return (_carrier, _owner, _status, _effectiveDate, _expirationDate);
    }

    function isCOIActive(bytes32 policyNumber) public view returns (bool result) {
        address manager = Doug(DOUG).getContract("coiManager");
        require (msg.sender == manager);
        address coiDb = Doug(DOUG).getContract("coiDB");
        require (coiDb != 0x0);
        result = CoiDB(coiDb).isCOIActive(policyNumber);
        return result;
    }

    function cancelCOI(bytes32 policyNumber) public returns (bool result) {
        address manager = Doug(DOUG).getContract("coiManager");
        require (msg.sender == manager);
        address coiDb = Doug(DOUG).getContract("coiDB");
        require (coiDb != 0x0);
        result = CoiDB(coiDb).cancelCOI(policyNumber);
        return result;
    }
}
