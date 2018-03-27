pragma solidity ^0.4.4;
import "./DougEnabled.sol";
import "./Doug.sol";
import "./DataHelper.sol";
import "./DateTime.sol";

contract CoiDB is DougEnabled{
    struct CoI {
        uint certificateNumber;
        uint ownerId;
        DataHelper.Stage status;
        uint effectiveDate;
        uint expirationDate;
    }

    uint numCertificates = 0;
    mapping (uint => CoI) cois;

    modifier senderIsController() {
        address _contractAddress = Doug(DOUG).getContract("coi");
        require (msg.sender == _contractAddress);
        _;
    }

    function createCoi(
        uint ownerId,
        uint _effectiveDate,
        uint _expirationDate
    )
        senderIsController public returns (uint id)
    {
        numCertificates++;
        CoI memory coi;
        DataHelper.Stage _status = DataHelper.Stage.Active;
        coi = CoI(numCertificates, ownerId, _status, _effectiveDate, _expirationDate);
        cois[numCertificates] = coi;
        return numCertificates;
    }

    function getCoi(uint certificateNumber) senderIsController public view
        returns(uint, uint, DataHelper.Stage, uint, uint)
    {
        CoI storage coi = cois[certificateNumber];
        return (coi.certificateNumber, coi.ownerId, coi.status, coi.effectiveDate, coi.expirationDate);
    }

    function updateStatus(uint certificateNumber, DataHelper.Stage _status) senderIsController public returns (bool result) {
        cois[certificateNumber].status = _status;
        return true;
    }

    function changeToExpired() senderIsController public {
        uint _expirationDate;
        for(uint i = 0; i <= numCertificates; i++) {
            _expirationDate = cois[i].expirationDate;
            if(
                DateTime.getYear(now) >= DateTime.getYear(_expirationDate) &&
                DateTime.getMonth(now) >= DateTime.getMonth(_expirationDate) &&
                DateTime.getDay(now) > DateTime.getDay(_expirationDate)
            ) {

                    cois[i].status = DataHelper.Stage.Expired;
            }
        }
    }
}
