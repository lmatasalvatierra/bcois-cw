pragma solidity ^0.4.4;

import "./DougEnabled.sol";
import "./Doug.sol";
import "./DataHelper.sol";
import "./PolicyDB.sol";

contract Policy is DougEnabled {
  modifier senderIsManager() {
      address _contractAddress = Doug(DOUG).getContract("coiManager");
      require (msg.sender == _contractAddress);
      _;
  }

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

  function getCoiStatus(uint _policyNumber) senderIsManager public view returns (DataHelper.Stage _status) {
      address policydb = obtainDBContract("policyDB");

      (, , , _status, , ) = PolicyDB(policydb).getPolicy(_policyNumber);
      return _status;
  }

  function cancelCOI(uint _policyNumber) senderIsManager public {
      address policydb = obtainDBContract("policyDB");

      PolicyDB(policydb).updateStatus(_policyNumber, DataHelper.Stage.Cancelled);
  }

  function changeToExpired() senderIsManager public {
      address policydb = obtainDBContract("policyDB");
      PolicyDB(policydb).changeToExpired();
  }

  function obtainDBContract(bytes32 DB) private view returns (address _contractAddress) {
      _contractAddress = Doug(DOUG).getContract(DB);
      require (_contractAddress != 0x0);
      return _contractAddress;
  }
}
