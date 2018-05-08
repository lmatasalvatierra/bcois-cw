pragma solidity ^0.4.23;
import "./Doug.sol";
import "./DougEnabled.sol";
import "./managers/UserManager.sol";
import "./managers/PolicyManager.sol";
import "./controllers/Coi.sol";
import "./controllers/User.sol";

contract COIManager is DougEnabled, UserManager, PolicyManager {
    address owner;

    event LogCreateCertificate
    (
        uint certificateNumber,
        bytes32 ownerEmail,
        bytes32 ownerName,
        uint effectiveDate
    );

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

    function createCoi(bytes32 email, uint effectiveDate, uint brokerId, uint[5] policies) public {
        address addressCoi = obtainControllerContract("coi");
        address user = obtainControllerContract("user");
        address policy = obtainControllerContract("policy");
        uint ownerId;
        bytes32 ownerName;

        (ownerId, , ownerName, ,) = User(user).getOwner(email);
        uint id = Coi(addressCoi).createCoi(ownerId, effectiveDate, brokerId);

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
        emit LogCreateCertificate(id, email, ownerName, effectiveDate);
    }

    function getCoi(uint certificateNumber) public view
        returns(uint _certificateNumber, bytes32 _ownerEmail, bytes32 _ownerName, uint _effectiveDate, string policies)
    {
        address addressCoi = obtainControllerContract("coi");
        address user = obtainControllerContract("user");
        uint ownerId;

        (_certificateNumber, ownerId, , _effectiveDate) = Coi(addressCoi).getCoi(certificateNumber);
        (_ownerEmail, _ownerName, ) = User(user).getOwner(ownerId);
        policies = getPoliciesOfCoi(certificateNumber);
    }

    function getPoliciesOfCoi(uint certificateNumber) private view returns (string coiString) {
        address addressCoi = obtainControllerContract("coi");
        uint[5] memory policies = Coi(addressCoi).getPoliciesOfCoi(certificateNumber);
        strings.slice[] memory objects = new strings.slice[](10);
        for(uint i = 0; i < policies.length; i++) {
            if(policies[i] != 0){
                objects[i*2] = getPolicyForCertificateView(policies[i]).toSlice();
                if(policies[i+1] != 0){
                    objects[(i*2)+1] = ",".toSlice();
                }
            } else {
                break;
            }
        }
        coiString = wrapObjectInArray("".toSlice().join(objects));
    }

    function getSummaryOfCoi(uint _certificateNumber) public view returns (string coiSummary) {
        address addressCoi = obtainControllerContract("coi");
        address user = obtainControllerContract("user");
        uint ownerId;
        bytes32 _ownerEmail;
        bytes32 _ownerName;
        uint _effectiveDate;

        (, ownerId, , _effectiveDate) = Coi(addressCoi).getCoi(_certificateNumber);
        (_ownerEmail, _ownerName, ) = User(user).getOwner(ownerId);
        strings.slice[] memory items = new strings.slice[](6);
        items[0] = itemJson("user_email", stringsUtil.bytes32ToString(_ownerEmail), false);
        items[1] = itemJson("user_name", stringsUtil.bytes32ToString(_ownerName), false);
        items[2] = itemJson("certificate_number", stringsUtil.uintToString(_certificateNumber), false);
        items[3] = itemJson("effective_date", stringsUtil.uintToString(_effectiveDate), true);
        coiSummary = wrapJsonObject("".toSlice().join(items));
    }

    function getCoisOfBroker(uint _brokerId) public view returns (string json) {
        address addressCoi = obtainControllerContract("coi");
        strings.slice[] memory objects = new strings.slice[](100);
        uint numCertificates;
        uint last;
        numCertificates = Coi(addressCoi).getNumCertificates();
        for(uint i = 1; i <= numCertificates; i++) {
            if(Coi(addressCoi).isCoiOfBroker(i, _brokerId)){
                objects[i*2] = getSummaryOfCoi(i).toSlice();
                objects[(i*2)+1] = ",".toSlice();
                last = (i*2)+1;
            }
        }
        objects[last] = "".toSlice();
        json = wrapObjectInArray("".toSlice().join(objects));
    }

    function obtainControllerContract(bytes32 controller) private view returns (address _contractAddress) {
        _contractAddress = Doug(DOUG).getContract(controller);
        require (_contractAddress != 0x0, "Controller contract has not been deployed");
        return _contractAddress;
    }
}
