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

    function createCoi(
        bytes32 policyNumber,
        address carrier,
        address owner,
        bytes32 effectiveDate,
        bytes32 expirationDate
    )
        senderIsManager public returns (bool result)
    {
        address coiDb = obtainDBContract("coiDB");
        result = CoiDB(coiDb).createCoi(policyNumber, carrier, owner, effectiveDate, expirationDate);
        return result;
    }

    function getCoi(bytes32 policyNumber) senderIsManager public view
        returns(address _carrier, address _owner, DataHelper.Stage _status, bytes32 _effectiveDate, bytes32 _expirationDate)
    {
        address coiDb = obtainDBContract("coiDB");

        (_carrier, _owner, _status, _effectiveDate, _expirationDate) = CoiDB(coiDb).getCoi(policyNumber);
        return (_carrier, _owner, _status, _effectiveDate, _expirationDate);
    }

    function getCoiStatus(bytes32 policyNumber) senderIsManager public view returns (DataHelper.Stage _status) {
        address coiDb = obtainDBContract("coiDB");

        (, , _status, , ) = CoiDB(coiDb).getCoi(policyNumber);
        return _status;
    }

    function cancelCOI(bytes32 policyNumber) senderIsManager public returns (bool result) {
        address coiDb = obtainDBContract("coiDB");

        result = CoiDB(coiDb).cancelCOI(policyNumber);
        return result;
    }

    function obtainDBContract(bytes32 DB) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(DB);
        require (_contractAddress != 0x0);
        return _contractAddress;
    }
}
