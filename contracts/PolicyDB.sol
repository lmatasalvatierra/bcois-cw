pragma solidity ^0.4.4;

import "./Database.sol";
import "./DataHelper.sol";
import "./DateTime.sol";

contract PolicyDB is Database {
    uint numPolicies;
    mapping (uint => DataHelper.Policy) policies;

    function createPolicy(
        uint _ownerId,
        bytes32 _name,
        uint _effectiveDate,
        uint _expirationDate
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
        return numPolicies;
    }

    function getPolicy(uint _policyNumber) senderIsController("policy") public view
        returns(uint, uint, bytes32, DataHelper.Stage, uint, uint)
    {
        DataHelper.Policy storage policy = policies[_policyNumber];
        return (policy.policyNumber, policy.ownerId, policy.name, policy.status, policy.effectiveDate, policy.expirationDate);
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
