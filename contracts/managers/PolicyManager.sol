pragma solidity ^0.4.23;

import "../libraries/strings.sol";
import "../libraries/stringsUtil.sol";
import "../controllers/Policy.sol";
import "../controllers/User.sol";

contract PolicyManager {
    using strings for *;

    event CreatePolicy
    (
        DataHelper.Stage status,
        bytes32 insuranceType,
        bytes32 ownerEmail,
        bytes16 ownerUUID,
        uint effectiveDate,
        uint expirationDate,
        bytes16 policyUUID
    );
    event LogCancelPolicy(bytes16 policyUUID, DataHelper.Stage status);

    function obtainControllerContract(bytes32 controller) private view returns (address _contractAddress);
    function itemJson(string key, string value, bool last) internal pure returns (strings.slice itemFinal);
    function wrapJsonObject(string object) internal pure returns (string result);
    function wrapObjectInArray(string object) internal pure returns (string result);

    function createPolicy(
    bytes32 _ownerEmail,
    bytes32 _name,
    uint _effectiveDate,
    uint _expirationDate,
    bytes16 _carrierUUID,
    bytes16 _policyUUID
    )
    external
    {
        address policy = obtainControllerContract("policy");
        address user = obtainControllerContract("user");
        uint result;
        bytes16 ownerUUID;
        (ownerUUID,) = User(user).getUserCredentials(_ownerEmail);
        if(ownerUUID != 0x0){
            result = Policy(policy).createPolicy(
              ownerUUID,
              _name,
              _effectiveDate,
              _expirationDate,
              _carrierUUID,
              _policyUUID);
              emit CreatePolicy(DataHelper.Stage.Active, _name, _ownerEmail, ownerUUID, _effectiveDate, _expirationDate, _policyUUID);
        }
        else {
            revert("Owner does no exist");
        }
    }

    function getPolicy(bytes16 policyUUID)
    external view
    returns(string policyString)
    {
        address policy = obtainControllerContract("policy");
        address user = obtainControllerContract("user");
        bytes32 _ownerName;
        bytes32 _userName;
        bytes32 _addressLine;
        bytes32 _name;
        DataHelper.Stage _status;
        uint _effectiveDate;
        uint _expirationDate;
        bytes16 _ownerUUID;
        (
        _ownerUUID,
        ,
        _name,
        _status,
        _effectiveDate,
        _expirationDate
        ) = Policy(policy).getPolicy(policyUUID);
        (_userName, _ownerName, _addressLine) = User(user).getOwner(_ownerUUID);
        strings.slice[] memory items = new strings.slice[](8);
        items[0] = itemJson("policy_uuid", stringsUtil.uuidToString(policyUUID), false);
        items[1] = itemJson("user_email", stringsUtil.bytes32ToString(_userName), false);
        items[2] = itemJson("insurance_type", stringsUtil.bytes32ToString(_name), false);
        items[3] = itemJson("status", stringsUtil.uintToString(uint(_status)), false);
        items[4] = itemJson("effective_date", stringsUtil.uintToString(_effectiveDate), false);
        items[5] = itemJson("expiration_date", stringsUtil.uintToString(_expirationDate), false);
        items[6] = itemJson("owner_name", stringsUtil.bytes32ToString(_ownerName), false);
        items[7] = itemJson("address",stringsUtil.bytes32ToString(_addressLine), true);
        policyString = wrapJsonObject("".toSlice().join(items));
    }

    function cancelPolicy(bytes16 _policyUUID) external {
        address policy = obtainControllerContract("policy");

        Policy(policy).cancelPolicy(_policyUUID);
        emit LogCancelPolicy(_policyUUID, DataHelper.Stage.Cancelled);
    }

    function changePolicyToExpired() external {
        address policy = obtainControllerContract("policy");
        Policy(policy).changePolicyToExpired();
    }

    function getPoliciesOfCarrier(bytes16 _carrierUUID) external view returns (string json) {
        address policy = obtainControllerContract("policy");
        strings.slice[] memory objects = new strings.slice[](100);
        uint numPolicies = Policy(policy).getNumPolicies();
        uint last;
        for(uint i = 1; i <= numPolicies; i++) {
            if(Policy(policy).isPolicyOfCarrier(i, _carrierUUID)){
                objects[i*2] = getSummaryOfPolicy(i).toSlice();
                objects[(i*2)+1] = ",".toSlice();
                last = (i*2)+1;
            }
        }
        objects[last] = "".toSlice();
        json = wrapObjectInArray("".toSlice().join(objects));
    }

    function getSummaryOfPolicy(uint policyNumber)
    internal view
    returns(string policyString)
    {
        address policy = obtainControllerContract("policy");
        address user = obtainControllerContract("user");
        bytes32 _userName;
        bytes32 _name;
        bytes16 _policyUUID;
        bytes16 _ownerUUID;
        DataHelper.Stage _status;
        uint _effectiveDate;
        uint _expirationDate;
        (_policyUUID,
        _ownerUUID,
        ,
        _name,
        _status,
        _effectiveDate,
        _expirationDate
        ) = Policy(policy).getPolicy(policyNumber);
        (_userName, ,) = User(user).getOwner(_ownerUUID);
        strings.slice[] memory items = new strings.slice[](6);
        items[0] = itemJson("policy_uuid", stringsUtil.uuidToString(_policyUUID), false);
        items[1] = itemJson("user_email", stringsUtil.bytes32ToString(_userName), false);
        items[2] = itemJson("insurance_type", stringsUtil.bytes32ToString(_name), false);
        items[3] = itemJson("status", stringsUtil.uintToString(uint(_status)), false);
        items[4] = itemJson("effective_date", stringsUtil.uintToString(_effectiveDate), false);
        items[5] = itemJson("expiration_date", stringsUtil.uintToString(_expirationDate), true);
        policyString = wrapJsonObject("".toSlice().join(items));
    }

    function getPolicyForCertificateView(bytes16 policyUUID)
    internal view
    returns(string policyString)
    {
        address policy = obtainControllerContract("policy");
        bytes32 _name;
        DataHelper.Stage _status;
        uint _effectiveDate;
        uint _expirationDate;
        (,
        ,
        _name,
        _status,
        _effectiveDate,
        _expirationDate
        ) = Policy(policy).getPolicy(policyUUID);
        strings.slice[] memory items = new strings.slice[](5);
        items[0] = itemJson("policy_uuid", stringsUtil.uuidToString(policyUUID), false);
        items[1] = itemJson("insurance_type", stringsUtil.bytes32ToString(_name), false);
        items[2] = itemJson("status", stringsUtil.uintToString(uint(_status)), false);
        items[3] = itemJson("effective_date", stringsUtil.uintToString(_effectiveDate), false);
        items[4] = itemJson("expiration_date", stringsUtil.uintToString(_expirationDate), true);
        policyString = wrapJsonObject("".toSlice().join(items));
    }

    function getPoliciesUUID() external view returns (bytes16[] _policiesUUID) {
        address policy = obtainControllerContract("policy");
        _policiesUUID = Policy(policy).getPoliciesUUID();
    }
}
