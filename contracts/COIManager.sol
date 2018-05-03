pragma solidity ^0.4.23;
import "./Doug.sol";
import "./DougEnabled.sol";
import "./managers/UserManager.sol";
import "./managers/PolicyManager.sol";
import "./controllers/Coi.sol";
import "./controllers/User.sol";

contract COIManager is DougEnabled, UserManager, PolicyManager {
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier isAdmin() {
        require(msg.sender == owner, "Sender is not an Administrator");
        _;
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

    function createCoi(bytes32 email, uint effectiveDate, uint[5] policies) public {
        address addressCoi = obtainControllerContract("coi");
        address user = obtainControllerContract("user");
        address policy = obtainControllerContract("policy");
        uint ownerId;

        (ownerId, ) = User(user).getUserCredentials(email);
        uint id = Coi(addressCoi).createCoi(ownerId, effectiveDate);

        for(uint i = 0; i < policies.length; i++) {
            if(policies[i] != 0) {
                require(Policy(policy).isPolicyValid(policies[i], ownerId));
                Coi(addressCoi).addPolicy(id, policies[i]);
            }
            else {
                break;
            }
        }
        User(user).addCertificate(email, id);
    }

    function getCoi(uint certificateNumber) public view
        returns(uint _certificateNumber, uint _ownerId, uint _effectiveDate)
    {
        address addressCoi = obtainControllerContract("coi");

        (_certificateNumber, _ownerId, _effectiveDate) = Coi(addressCoi).getCoi(certificateNumber);
        return (_certificateNumber, _ownerId, _effectiveDate);
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

    function obtainControllerContract(bytes32 controller) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(controller);
        require (_contractAddress != 0x0, "Controller contract has not been deployed");
        return _contractAddress;
    }
}
