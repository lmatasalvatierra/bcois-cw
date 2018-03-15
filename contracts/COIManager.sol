pragma solidity ^0.4.4;
import "./Doug.sol";
import "./DataHelper.sol";
import "./Coi.sol";
import "./DougEnabled.sol";
import "./Permission.sol";

contract COIManager is DougEnabled {
    address owner;

    function COIManager() public {
        owner = msg.sender;
    }

    modifier isAdmin() {
        require(getPermission(msg.sender) == DataHelper.Permission.Admin);
        _;
    }

    modifier isAgency() {
        require(getPermission(msg.sender) == DataHelper.Permission.Agency);
        _;
    }

    modifier isOwner() {
        require(getPermission(msg.sender) == DataHelper.Permission.Owner);
        _;
    }

    function createCoi(
        bytes32 policyNumber,
        address carrier,
        address _owner,
        uint effectiveDate,
        uint expirationDate
    )
        isAgency public returns (bool result)
    {
        address addressCoi = obtainControllerContract("coi");
        address perm = obtainControllerContract("perm");
        Permission(perm).setPermission(_owner, DataHelper.Permission.Owner);
        result = Coi(addressCoi).createCoi(policyNumber, carrier, _owner, effectiveDate, expirationDate);
        return result;
    }

    function getCoi(bytes32 policyNumber) public view
        returns(address _carrier, address _owner, DataHelper.Stage _status, uint _effectiveDate, uint _expirationDate)
    {
        address addressCoi = obtainControllerContract("coi");
        (_carrier, _owner, _status, _effectiveDate, _expirationDate) = Coi(addressCoi).getCoi(policyNumber);
        //assert(msg.sender == _owner || msg.sender == _carrier || uint(getPermission(msg.sender)) > 2);
        return (_carrier, _owner, _status, _effectiveDate, _expirationDate);
    }

    function getCoiStatus(bytes32 policyNumber) public view returns (DataHelper.Stage _status) {
        address addressCoi = obtainControllerContract("coi");
        _status = Coi(addressCoi).getCoiStatus(policyNumber);
        return _status;
    }

    function cancelCOI(bytes32 policyNumber) isAgency public returns (bool result) {
        address addressCoi = obtainControllerContract("coi");
        result = Coi(addressCoi).cancelCOI(policyNumber);
        return result;
    }

    function changeToExpired() isAdmin public {
        address addressCoi = obtainControllerContract("coi");
        Coi(addressCoi).changeToExpired();
    }

    function allowToGetCoi(bytes32 policyNumber, address getter) isOwner public {
        address addressCoi = obtainControllerContract("coi");
        Coi(addressCoi).allowToGetCoi(policyNumber, getter);
    }

    function setPermission(address _address, DataHelper.Permission _perm) isAdmin public {
        address perm = obtainControllerContract("perm");
        Permission(perm).setPermission(_address, _perm);
    }

    function getPermission(address _address) private view returns (DataHelper.Permission result) {
        address perm = obtainControllerContract("perm");
        result = Permission(perm).getPermission(_address);
    }

    function obtainControllerContract(bytes32 controller) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(controller);
        require (_contractAddress != 0x0);
        return _contractAddress;
    }
}
