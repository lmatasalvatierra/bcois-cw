pragma solidity ^0.4.4;
import "./Doug.sol";
import "./DataHelper.sol";
import "./Coi.sol";
import "./DougEnabled.sol";
import "./Permission.sol";
import "./User.sol";
import "./Policy.sol";
import "./strings.sol";

contract COIManager is DougEnabled {
    using strings for *;
    address owner;

    function COIManager() public {
        owner = msg.sender;
    }

    modifier isAdmin() {
        require(msg.sender == owner);
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
        require(getPolicyStatus(policyNumber) == DataHelper.Stage.Active);
        address addressCoi = obtainControllerContract("coi");

        Coi(addressCoi).addPolicy(certificateNumber, policyNumber);
    }

    function getPoliciesOfCoi(uint certificateNumber) public view returns (uint[10] policies) {
        address addressCoi = obtainControllerContract("coi");

        policies = Coi(addressCoi).getPoliciesOfCoi(certificateNumber);
    }

    // Policy Methods

    function createPolicy(
      uint _ownerId,
      bytes32 _name,
      uint _effectiveDate,
      uint _expirationDate,
      uint _carrierId
    )
     public returns (uint result)
    {
        address policy = obtainControllerContract("policy");
        result = Policy(policy).createPolicy(_ownerId, _name, _effectiveDate, _expirationDate, _carrierId);
        return result;
    }

    function getPolicy(
     uint policyNumber
    )
    public view
    returns(
     uint _policyNumber,
     uint _ownerId,
     bytes32 _name,
     DataHelper.Stage _status,
     uint _effectiveDate,
     uint _expirationDate,
     uint _carrierId
    )
    {
        address policy = obtainControllerContract("policy");

        (_policyNumber,
         _ownerId,
         _name,
         _status,
         _effectiveDate,
         _expirationDate,
         _carrierId
         ) = Policy(policy).getPolicy(policyNumber);
         return (_policyNumber, _ownerId, _name, _status, _effectiveDate, _expirationDate, _carrierId);
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

    // Permission Methods

    function allowGuestToCheckCoi(bytes32 policyNumber, address guest) public {
        address perm = obtainControllerContract("perm");
        Permission(perm).addGuest(guest, policyNumber, msg.sender);
    }

    function setPermission(bytes32 policyNumber, address _agency, address _owner) private {
        address perm = obtainControllerContract("perm");
        Permission(perm).setPermission(policyNumber, _agency, _owner);
    }

    // User Methods
    function login(bytes32 email, bytes32 _passwordHash) public view
    returns (DataHelper.UserType result) {
        address user = obtainControllerContract("user");
        result = User(user).login(email, _passwordHash);
        return result;
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
    }

    function addCertificate(bytes32 email, uint id) public {
        address user = obtainControllerContract("user");
        User(user).addCertificate(email, id);
    }

    function getOwner(bytes32 email)
    public
    view
    returns (bytes32 _email, bytes32 _name, bytes32 _addressLine, uint[20] _certificates)
    {
        address user = obtainControllerContract("user");
        (_email, _name, _addressLine, _certificates) = User(user).getOwner(email);
        return (_email, _name, _addressLine, _certificates);
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
    }

    function getCarrier(bytes32 email)
    public
    view
    returns (bytes32 _name, uint _naicCode, bytes32 _email)
    {
        address user = obtainControllerContract("user");

        (_name, _naicCode, _email) = User(user).getCarrier(email);
        return (_name, _naicCode, _email);
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
    }

    function getBroker(bytes32 email)
    public
    view
    returns (bytes32 _name, bytes32 _email, bytes32 _contactPhone , bytes32 _addressLine)
    {
        address user = obtainControllerContract("user");

        (_name, _email, _contactPhone, _addressLine) = User(user).getBroker(email);
        return (_name, _email, _contactPhone, _addressLine);
    }

    // Helper Methods

    function obtainControllerContract(bytes32 controller) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(controller);
        require (_contractAddress != 0x0);
        return _contractAddress;
    }
}
