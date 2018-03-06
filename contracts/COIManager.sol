pragma solidity ^0.4.4;
import "./Doug.sol";
import "./DataHelper.sol";
import "./Carrier.sol";
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

    function createCoi(
        bytes32 policyNumber,
        address carrier,
        address _owner,
        bytes32 effectiveDate,
        bytes32 expirationDate
    )
        isAgency public returns (bool result)
    {
        address name_carrier = Doug(DOUG).getContract("carrier");
        require(name_carrier != 0x0);
        result = Carrier(name_carrier).createCoi(policyNumber, carrier, _owner, effectiveDate, expirationDate);
        return result;
    }

    function getCoi(bytes32 policyNumber) public view
        returns(address _carrier, address _owner, DataHelper.Stage _status, bytes32 _effectiveDate, bytes32 _expirationDate)
    {
        address carrier = Doug(DOUG).getContract("carrier");
        require (carrier != 0x0);
        (_carrier, _owner, _status, _effectiveDate, _expirationDate) = Carrier(carrier).getCoi(policyNumber);
        assert(msg.sender == _owner || msg.sender == _carrier || uint(getPermission(msg.sender)) > 2);
        return (_carrier, _owner, _status, _effectiveDate, _expirationDate);
    }

    function isCOIActive(bytes32 policyNumber) public view returns (bool result) {
        address carrier = Doug(DOUG).getContract("carrier");
        require (carrier != 0x0);
        result = Carrier(carrier).isCOIActive(policyNumber);
        return result;
    }

    function cancelCOI(bytes32 policyNumber) isAgency public returns (bool result) {
        address carrier = Doug(DOUG).getContract("carrier");
        require (carrier != 0x0);
        result = Carrier(carrier).cancelCOI(policyNumber);
        return result;
    }

    function setPermission(address _address, DataHelper.Permission _perm) isAdmin public {
        address perm = Doug(DOUG).getContract("perm");
        require (perm != 0x0);
        Permission(perm).setPermission(_address, _perm);
    }

    function getPermission(address _address) private view returns (DataHelper.Permission result) {
        address perm = Doug(DOUG).getContract("perm");
        require (perm != 0x0);
        result = Permission(perm).getPermission(_address);
    }
}
