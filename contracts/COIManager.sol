pragma solidity ^0.4.23;
import "./Doug.sol";
import "./DataHelper.sol";
import "./Coi.sol";
import "./DougEnabled.sol";
import "./Permission.sol";
import "./User.sol";
import "./Policy.sol";
import "./strings.sol";
import "./stringsUtil.sol";

contract COIManager is DougEnabled {
    using strings for *;
    address owner;

    event CreatePolicy
    (
        DataHelper.Stage status,
        bytes32 insuranceType,
        bytes32 ownerEmail,
        uint policyNumber,
        uint ownerId,
        uint effectiveDate,
        uint expirationDate
    );
    event LogCreateOwner(bytes32 name, bytes32 email, bytes32 addressLine);
    event LogCreateCarrier(bytes32 name, bytes32 email, uint naicCode);
    event LogCreateBroker(bytes32 name, bytes32 email, bytes32 contactPhone, bytes32 addressLine);

    constructor() public {
        owner = msg.sender;
    }

    modifier isAdmin() {
        require(msg.sender == owner, "Sender is not an Administrator");
        _;
    }
    // COI Methods

    function createCoi(bytes32 email) public {
        address addressCoi = obtainControllerContract("coi");
        address user = obtainControllerContract("user");
        uint ownerId;
        (ownerId, ) = User(user).getUserCredentials(email);

        uint result = Coi(addressCoi).createCoi(ownerId);
        User(user).addCertificate(email, result);
    }

    function getCoi(uint certificateNumber) public view
        returns(uint _certificateNumber, uint _ownerId)
    {
        address addressCoi = obtainControllerContract("coi");

        (_certificateNumber, _ownerId) = Coi(addressCoi).getCoi(certificateNumber);
        return (_certificateNumber, _ownerId);
    }

    function addPolicy(uint certificateNumber, uint policyNumber) public {
        require(getPolicyStatus(policyNumber) == DataHelper.Stage.Active, "The policy is not active");
        address addressCoi = obtainControllerContract("coi");

        Coi(addressCoi).addPolicy(certificateNumber, policyNumber);
    }

    function getPoliciesOfCoi(uint certificateNumber) public view returns (string coiString) {
        address addressCoi = obtainControllerContract("coi");
        uint[5] memory policies = Coi(addressCoi).getPoliciesOfCoi(certificateNumber);
        strings.slice[] memory objects = new strings.slice[](10);
        for(uint i = 0; i < policies.length; i++) {
            if(policies[i] != 0){
                objects[i*2] = getPolicy(policies[i]).toSlice();
                if(policies[i+1] != 0){
                    objects[(i*2)+1] = ",".toSlice();
                }
            } else {
                break;
            }
        }
        coiString = wrapObjectInArray("".toSlice().join(objects));
    }

    // Policy Methods

    function createPolicy(
      bytes32 _ownerEmail,
      bytes32 _name,
      uint _effectiveDate,
      uint _expirationDate,
      uint _carrierId
    )
     public
    {
        address policy = obtainControllerContract("policy");
        address user = obtainControllerContract("user");
        uint result;
        uint ownerId;
        (ownerId,) = User(user).getUserCredentials(_ownerEmail);
        if(ownerId != 0){
            result = Policy(policy).createPolicy(
                ownerId,
                _name,
                _effectiveDate,
                _expirationDate,
                _carrierId);
                emit CreatePolicy(DataHelper.Stage.Active, _name, _ownerEmail, result, ownerId, _effectiveDate, _expirationDate);
        }
        else {
            revert("Owner does no exist");
        }
    }

    function getPolicy(uint policyNumber)
    public view
    returns(string policyString)
    {
        address policy = obtainControllerContract("policy");
        address user = obtainControllerContract("user");
        bytes32 _ownerName;
        bytes32 _userName;
        bytes32 _addressLine;
        uint _policyNumber;
        uint _ownerId;
        bytes32 _name;
        DataHelper.Stage _status;
        uint _effectiveDate;
        uint _expirationDate;
        (_policyNumber,
         _ownerId,
         _name,
         _status,
         _effectiveDate,
         _expirationDate,
         ) = Policy(policy).getPolicy(policyNumber);
        (_userName, _ownerName, _addressLine) = User(user).getOwner(_ownerId);
        strings.slice[] memory items = new strings.slice[](8);
        items[0] = itemJson("policy_number", stringsUtil.uintToString(_policyNumber), false);
        items[1] = itemJson("user_email", stringsUtil.bytes32ToString(_userName), false);
        items[2] = itemJson("insurance_type", stringsUtil.bytes32ToString(_name), false);
        items[3] = itemJson("status", stringsUtil.uintToString(uint(_status)), false);
        items[4] = itemJson("effective_date", stringsUtil.uintToString(_effectiveDate), false);
        items[5] = itemJson("expiration_date", stringsUtil.uintToString(_expirationDate), false);
        items[6] = itemJson("owner_name", stringsUtil.bytes32ToString(_ownerName), false);
        items[7] = itemJson("address",stringsUtil.bytes32ToString(_addressLine), true);
        policyString = wrapJsonObject("".toSlice().join(items));
    }

    function itemJson(
        string key,
        string value,
        bool last
    )
    internal pure
    returns (strings.slice itemFinal)
    {
        strings.slice[] memory item = new strings.slice[](8);
        item[0] = '"'.toSlice();
        item[1] = key.toSlice();
        item[2] = '"'.toSlice();
        item[3] = ":".toSlice();
        item[4] = '"'.toSlice();
        item[5] = value.toSlice();
        item[6] = '"'.toSlice();
        if(!last) {
            item[7] = ",".toSlice();
        } else {
            item[7] = "".toSlice();
        }
        itemFinal = "".toSlice().join(item).toSlice();
    }

    function wrapJsonObject(string object) internal pure returns (string result) {
        strings.slice[] memory parts = new strings.slice[](3);
        parts[0] = "{".toSlice();
        parts[1] = object.toSlice();
        parts[2] = "}".toSlice();
        result = "".toSlice().join(parts);
    }

    function wrapObjectInArray(string object) internal pure returns (string result) {
        strings.slice[] memory parts = new strings.slice[](3);
        parts[0] = "[".toSlice();
        parts[1] = object.toSlice();
        parts[2] = "]".toSlice();
        result = "".toSlice().join(parts);
    }

    function getPolicyStatus(uint _policyNumber) public view returns (DataHelper.Stage _status) {
        address policy = obtainControllerContract("policy");

        (, , , _status, , , ) = Policy(policy).getPolicy(_policyNumber);
        return _status;
    }

    function cancelPolicy(uint _policyNumber) public {
        address policy = obtainControllerContract("policy");

        Policy(policy).cancelPolicy(_policyNumber);
    }

    function changePolicyToExpired() public {
        address policy = obtainControllerContract("policy");
        Policy(policy).changePolicyToExpired();
    }

    // User Methods
    function login(bytes32 email, bytes32 _passwordHash) public view
    returns (uint userId, DataHelper.UserType userType) {
        address user = obtainControllerContract("user");
        (userId, userType) = User(user).login(email, _passwordHash);
        return (userId, userType);
    }

    function createOwner(
        bytes32 _email,
        string _password,
        bytes32 _name,
        bytes32 _addressLine
    )
    public
    {
        address user = obtainControllerContract("user");

        User(user).createOwner(_email, _password, _name, _addressLine);
        emit LogCreateOwner(_name, _email, _addressLine);
    }

    function addCertificate(bytes32 email, uint id) public {
        address user = obtainControllerContract("user");
        User(user).addCertificate(email, id);
    }

    function createCarrier(
        bytes32 _email,
        string _password,
        bytes32 _name
    )
    public
    {
        address user = obtainControllerContract("user");

        User(user).createCarrier(_email, _password, _name);
        emit LogCreateCarrier(_name, _email, 1);
    }

    function createBroker(
        bytes32 _email,
        string _password,
        bytes32 _name,
        bytes32 _contactPhone,
        bytes32 _addressLine
    )
    public
    {
        address user = obtainControllerContract("user");

        User(user).createBroker(_email, _password, _name, _contactPhone, _addressLine);
        emit LogCreateBroker(_name, _email, _contactPhone, _addressLine);
    }

    // Helper Methods

    function obtainControllerContract(bytes32 controller) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(controller);
        require (_contractAddress != 0x0, "Controller contract has not been deployed");
        return _contractAddress;
    }
}
