pragma solidity ^0.4.4;
import "./Doug.sol";
import "./DataHelper.sol";
import "./Coi.sol";
import "./DougEnabled.sol";
import "./Permission.sol";
import "./User.sol";

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

    function createCoi(
        bytes32 policyNumber,
        address carrier,
        address _owner,
        uint effectiveDate,
        uint expirationDate
    )
        public returns (bool result)
    {
        address addressCoi = obtainControllerContract("coi");

        result = Coi(addressCoi).createCoi(policyNumber, effectiveDate, expirationDate);
        setPermission(policyNumber, carrier, _owner);
        return result;
    }

    function getCoi(bytes32 policyNumber) public view
        returns(DataHelper.Stage _status, uint _effectiveDate, uint _expirationDate)
    {
        address addressCoi = obtainControllerContract("coi");
        address perm = obtainControllerContract("perm");
        require(Permission(perm).isPermittedToGetCoi(policyNumber, msg.sender));

        (_status, _effectiveDate, _expirationDate) = Coi(addressCoi).getCoi(policyNumber);
        return (_status, _effectiveDate, _expirationDate);
    }

    function getCoiStatus(bytes32 policyNumber) public view returns (DataHelper.Stage _status) {
        address addressCoi = obtainControllerContract("coi");
        _status = Coi(addressCoi).getCoiStatus(policyNumber);
        return _status;
    }

    function cancelCOI(bytes32 policyNumber) public returns (bool result) {
        address addressCoi = obtainControllerContract("coi");
        result = Coi(addressCoi).cancelCOI(policyNumber);
        return result;
    }

    function changeToExpired() isAdmin public {
        address addressCoi = obtainControllerContract("coi");
        Coi(addressCoi).changeToExpired();
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
        address user = obtainControllerContract('user');

        User(user).createOwner(_email, _password, _name, _addressLine);
    }

    function loginOwner(bytes32 email, bytes32 password) public view
    returns (bool result) {
        address user = obtainControllerContract('user');
        result = User(user).loginOwner(email, password);
    }

    function addCertificate(bytes32 email, uint id) public {
        address user = obtainControllerContract('user');
        User(user).addCertificate(email, id);
    }

    function getOwner(bytes32 email)
    public
    view
    returns (bytes32 _email, bytes32 _name, bytes32 _addressLine, uint[20] _certificates)
    {
        address user = obtainControllerContract('user');
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
