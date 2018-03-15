pragma solidity ^0.4.4;
import "./DougEnabled.sol";
import "./Doug.sol";
import "./DataHelper.sol";
import "./DateTime.sol";

contract CoiDB is DougEnabled{
    struct CoI {
        address carrier;
        address owner;
        DataHelper.Stage status;
        uint effectiveDate;
        uint expirationDate;
        address[] allowedGetters;
    }

    uint numIds;
    mapping (uint => CoI) cois;
    mapping (bytes32 => uint) ids;

    modifier senderIsController() {
        address _contractAddress = Doug(DOUG).getContract("coi");
        require (msg.sender == _contractAddress);
        _;
    }

    function CoiDB() public {
        numIds = 0;
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
        coi = CoI(_carrier, _owner, _status, _effectiveDate, _expirationDate, new address[](10));
        ids[policyNumber] = numIds;
        cois[numIds] = coi;
        numIds++;
        return true;
    }

    function getCoi(bytes32 policyNumber) senderIsController public view
        returns(address, address, DataHelper.Stage, uint, uint)
    {
        CoI memory coi;
        coi = cois[ids[policyNumber]];
        return (coi.carrier, coi.owner, coi.status, coi.effectiveDate, coi.expirationDate);
    }

    function updateStatus(bytes32 policyNumber, DataHelper.Stage _status) senderIsController public returns (bool result) {
        cois[ids[policyNumber]].status = _status;
        return true;
    }

    function changeToExpired() senderIsController public {
        uint _expirationDate;
        for(uint i = 0; i < numIds; i++) {
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

    function allowToGetCoi(bytes32 policyNumber, address getter) senderIsController public {
        cois[ids[policyNumber]].allowedGetters.push(getter);
    }
}
