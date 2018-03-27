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
        uint ownerId,
        uint effectiveDate,
        uint expirationDate
    )
        senderIsManager public returns (uint result)
    {
        address coiDb = obtainDBContract("coiDB");
        result = CoiDB(coiDb).createCoi(ownerId, effectiveDate, expirationDate);
        return result;
    }

    function getCoi(uint certificateNumber) senderIsManager public view
        returns(uint _certificateNumber, uint _ownerId, DataHelper.Stage _status, uint _effectiveDate, uint _expirationDate)
    {
        address coiDb = obtainDBContract("coiDB");

        (_certificateNumber, _ownerId, _status, _effectiveDate, _expirationDate) = CoiDB(coiDb).getCoi(certificateNumber);
        return (_certificateNumber, _ownerId, _status, _effectiveDate, _expirationDate);
    }

    function getCoiStatus(uint certificateNumber) senderIsManager public view returns (DataHelper.Stage _status) {
        address coiDb = obtainDBContract("coiDB");

        (, , _status, , ) = CoiDB(coiDb).getCoi(certificateNumber);
        return _status;
    }

    function cancelCOI(uint certificateNumber) senderIsManager public returns (bool result) {
        address coiDb = obtainDBContract("coiDB");

        result = CoiDB(coiDb).updateStatus(certificateNumber, DataHelper.Stage.Cancelled);
        return result;
    }

    function changeToExpired() senderIsManager public {
        address coiDb = obtainDBContract("coiDB");
        CoiDB(coiDb).changeToExpired();
    }

    function obtainDBContract(bytes32 DB) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(DB);
        require (_contractAddress != 0x0);
        return _contractAddress;
    }
}
