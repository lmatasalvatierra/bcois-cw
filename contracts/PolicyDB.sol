pragma solidity ^0.4.4;

import "./DougEnabled.sol";
import "./Doug.sol";
import "./DataHelper.sol";
import "./DateTime.sol";

contract PolicyDB is DougEnabled{
  uint numPolicies;
  mapping (uint => DataHelper.Policy) policies;

  modifier senderIsController() {
      address _contractAddress = Doug(DOUG).getContract("policy");
      require (msg.sender == _contractAddress);
      _;
  }

  function createPolicy(
      uint _ownerId,
      bytes32 _name,
      uint _effectiveDate,
      uint _expirationDate
  )
      senderIsController public returns (uint id)
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

  function getPolicy(uint _policyNumber) senderIsController public view
      returns(uint, uint, bytes32, DataHelper.Stage, uint, uint)
  {
      DataHelper.Policy storage policy = policies[_policyNumber];
      return (policy.policyNumber, policy.ownerId, policy.name, policy.status, policy.effectiveDate, policy.expirationDate);
  }

  function updateStatus(uint policyNumber, DataHelper.Stage _status) senderIsController public {
      policies[policyNumber].status = _status;
  }

  function changeToExpired() senderIsController public {
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
