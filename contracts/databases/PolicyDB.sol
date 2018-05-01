pragma solidity ^0.4.23;

import "./Database.sol";
import "../libraries/DataHelper.sol";
import "../libraries/DateTime.sol";

contract PolicyDB is Database {
    uint numPolicies;
    mapping (uint => DataHelper.Policy) policies;

    function createPolicy(
        uint _ownerId,
        bytes32 _name,
        uint _effectiveDate,
        uint _expirationDate,
        uint _carrierId
    )
        senderIsController("policy") public returns (uint id)
    {
        numPolicies++;
        DataHelper.Policy storage policy = policies[numPolicies];
        policy.policyNumber = numPolicies;
        policy.ownerId = _ownerId;
        policy.name = _name;
        policy.status = DataHelper.Stage.Active;
        policy.effectiveDate = _effectiveDate;
        policy.expirationDate = _expirationDate;
        policy.carrierId = _carrierId;
        return numPolicies;
    }

    function getPolicy(uint _policyNumber) senderIsController("policy") public view
        returns(uint, uint, bytes32, DataHelper.Stage, uint, uint, uint)
    {
        DataHelper.Policy storage policy = policies[_policyNumber];
        assert(policy.ownerId != 0);
        return (policy.policyNumber, policy.ownerId, policy.name, policy.status, policy.effectiveDate, policy.expirationDate, policy.carrierId);
    }

    function updateStatus(uint policyNumber, DataHelper.Stage _status) senderIsController("policy") public {
        policies[policyNumber].status = _status;
    }

    function changeToExpired() senderIsController("policy") public {
        uint _expirationDate;
        for(uint i = 0; i <= numPolicies; i++) {
            _expirationDate = policies[i].expirationDate;
            if(
                DateTime.getYear(now) >= DateTime.getYear(_expirationDate) &&
                DateTime.getMonth(now) >= DateTime.getMonth(_expirationDate) &&
                DateTime.getDay(now) > DateTime.getDay(_expirationDate)
            ) {
                    policies[i].status = DataHelper.Stage.Expired;
            }
        }
    }
}
