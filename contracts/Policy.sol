pragma solidity ^0.4.4;

import "./Controller.sol";
import "./DataHelper.sol";
import "./PolicyDB.sol";

contract Policy is Controller {
    function createPolicy(
        uint _ownerId,
        bytes32 _name,
        uint _effectiveDate,
        uint _expirationDate
    )
        senderIsManager public returns (uint result)
    {
        address policydb = obtainDBContract("policyDB");
        result = PolicyDB(policydb).createPolicy(_ownerId, _name, _effectiveDate, _expirationDate);
        return result;
    }

    function getPolicy(
      uint policyNumber
    )
    senderIsManager
    public view
    returns(
      uint _policyNumber,
      uint _ownerId,
      bytes32 _name,
      DataHelper.Stage _status,
      uint _effectiveDate,
      uint _expirationDate)
    {
        address policydb = obtainDBContract("policyDB");

        (_policyNumber,
         _ownerId,
         _name,
         _status,
         _effectiveDate,
         _expirationDate
        ) = PolicyDB(policydb).getPolicy(policyNumber);
        return (_policyNumber, _ownerId, _name, _status, _effectiveDate, _expirationDate);
    }

    function getPolicyStatus(uint _policyNumber) senderIsManager public view returns (DataHelper.Stage _status) {
        address policydb = obtainDBContract("policyDB");

        (, , , _status, , ) = PolicyDB(policydb).getPolicy(_policyNumber);
        return _status;
    }

    function cancelPolicy(uint _policyNumber) senderIsManager public {
        address policydb = obtainDBContract("policyDB");

        PolicyDB(policydb).updateStatus(_policyNumber, DataHelper.Stage.Cancelled);
    }

    function changePolicyToExpired() senderIsManager public {
        address policydb = obtainDBContract("policyDB");
        PolicyDB(policydb).changeToExpired();
    }
}
