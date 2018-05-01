pragma solidity ^0.4.23;

import "../libraries/strings.sol";
import "../libraries/stringsUtil.sol";
import "../controllers/Coi.sol";
import "../controllers/User.sol";

contract CertificateManager {

    function obtainControllerContract(bytes32 controller) private view returns (address _contractAddress);
    function itemJson(string key, string value, bool last) internal pure returns (strings.slice itemFinal);
    function wrapJsonObject(string object) internal pure returns (string result);
    function wrapObjectInArray(string object) internal pure returns (string result);

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
}
