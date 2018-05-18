pragma solidity ^0.4.23;

import "./Database.sol";
import "../libraries/DataHelper.sol";
import "../libraries/DateTime.sol";

contract PolicyDB is Database {
    uint numPolicies;
    mapping (uint => DataHelper.Policy) policies;
    mapping (bytes16 => uint) uuidToId;
    bytes16[] policiesUUID;

    function createPolicy(
        bytes16 _ownerUUID,
        bytes32 _name,
        uint _effectiveDate,
        uint _expirationDate,
        bytes16 _carrierUUID,
        bytes16 _policyUUID
    )
        senderIsController("policy") public returns (uint id)
    {
        numPolicies++;
        uuidToId[_policyUUID] = numPolicies;
        policiesUUID.push(_policyUUID);
        DataHelper.Policy storage policy = policies[numPolicies];
        policy.policyNumber = numPolicies;
        policy.ownerUUID = _ownerUUID;
        policy.name = _name;
        policy.status = DataHelper.Stage.Active;
        policy.effectiveDate = _effectiveDate;
        policy.expirationDate = _expirationDate;
        policy.carrierUUID = _carrierUUID;
        policy.policyUUID = _policyUUID;
        return numPolicies;
    }

    function getPolicy(uint _policyNumber) senderIsController("policy") public view
        returns(bytes16, bytes16, bytes16, bytes32, DataHelper.Stage, uint, uint)
    {
        DataHelper.Policy storage policy = policies[_policyNumber];
        require(policy.policyUUID != 0x0, "The policy does not exist");
        return (policy.policyUUID, policy.ownerUUID, policy.carrierUUID, policy.name, policy.status, policy.effectiveDate, policy.expirationDate);
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

    function getNumPolicies() senderIsController("policy") public view returns (uint) {
        return numPolicies;
    }

    function getPolicyNumber(bytes16 policyUUID) senderIsController("policy")  public view returns (uint) {
        return uuidToId[policyUUID];
    }

    function getPoliciesUUID() senderIsController("policy") public view returns (bytes16[]) {
        return policiesUUID;
    }
}
