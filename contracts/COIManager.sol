pragma solidity ^0.4.4;
import "./Doug.sol";
import "./DataHelper.sol";
import "./Coi.sol";
import "./DougEnabled.sol";
import "./Permission.sol";
import "./User.sol";
import "./Policy.sol";

contract COIManager is DougEnabled {
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
        uint ownerId = User(user).getOwnerId(email);

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

    // Policy Methods

    function createPolicy(
      uint _ownerId,
      bytes32 _name,
      uint _effectiveDate,
      uint _expirationDate
    )
     public returns (uint result)
    {
        address policy = obtainControllerContract("policy");
        result = Policy(policy).createPolicy(_ownerId, _name, _effectiveDate, _expirationDate);
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
     uint _expirationDate)
    {
        address policy = obtainControllerContract("policy");

        (_policyNumber,
         _ownerId,
         _name,
         _status,
         _effectiveDate,
         _expirationDate
         ) = Policy(policy).getPolicy(policyNumber);
         return (_policyNumber, _ownerId, _name, _status, _effectiveDate, _expirationDate);
    }

    function getPolicyStatus(uint _policyNumber) public view returns (DataHelper.Stage _status) {
        address policy = obtainControllerContract("policy");

        (, , , _status, , ) = Policy(policy).getPolicy(_policyNumber);
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

    function createOwner(
        bytes32 _email,
        bytes32 _password,
        bytes32 _name,
        bytes32 _addressLine
    )
    public
    {
        address user = obtainControllerContract("user");

        User(user).createOwner(_email, _password, _name, _addressLine);
    }

    function loginOwner(bytes32 email, bytes32 password) public view
    returns (bool result) {
        address user = obtainControllerContract("user");
        result = User(user).loginOwner(email, password);
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

    // Helper Methods

    function obtainControllerContract(bytes32 controller) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(controller);
        require (_contractAddress != 0x0);
        return _contractAddress;
    }
}
