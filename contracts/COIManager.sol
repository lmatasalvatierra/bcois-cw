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
        uint effectiveDate,
        bytes16 certificateUUID
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

    function createCoi(bytes32 email, uint effectiveDate, uint brokerId, bytes16[5] policies, bytes16 certificateUUID) external {
        address addressCoi = obtainControllerContract("coi");
        address user = obtainControllerContract("user");
        address policy = obtainControllerContract("policy");
        uint ownerId;
        bytes32 ownerName;

        (ownerId, , ownerName, ,) = User(user).getOwner(email);
        uint id = Coi(addressCoi).createCoi(ownerId, effectiveDate, brokerId, certificateUUID);

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
        emit LogCreateCertificate(id, email, ownerName, effectiveDate, certificateUUID);
    }

    function getCoi(bytes16 certificateUUID) external view
        returns(bytes16 _certificateUUID, bytes32 _ownerEmail, bytes32 _ownerName, uint _effectiveDate, string policies)
    {
        address addressCoi = obtainControllerContract("coi");
        address user = obtainControllerContract("user");
        uint ownerId;

        (_certificateUUID, ownerId, , _effectiveDate) = Coi(addressCoi).getCoi(certificateUUID);
        (_ownerEmail, _ownerName, ) = User(user).getOwner(ownerId);
        policies = getPoliciesOfCoi(certificateUUID);
    }

    function getPoliciesOfCoi(bytes16 certificateUUID) internal view returns (string coiString) {
        address addressCoi = obtainControllerContract("coi");
        bytes16[5] memory policies = Coi(addressCoi).getPoliciesOfCoi(certificateUUID);
        strings.slice[] memory objects = new strings.slice[](10);
        for(uint i = 0; i < policies.length; i++) {
            if(policies[i] != 0x0){
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

    function getSummaryOfCoiForBroker(uint _certificateNumber) internal view returns (string coiSummary) {
        address addressCoi = obtainControllerContract("coi");
        address user = obtainControllerContract("user");
        uint ownerId;
        bytes32 _ownerEmail;
        bytes32 _ownerName;
        bytes16 _certificateUUID;
        uint _effectiveDate;

        (_certificateUUID, ownerId, , _effectiveDate) = Coi(addressCoi).getCoi(_certificateNumber);
        (_ownerEmail, _ownerName, ) = User(user).getOwner(ownerId);
        strings.slice[] memory items = new strings.slice[](4);
        items[0] = itemJson("user_email", stringsUtil.bytes32ToString(_ownerEmail), false);
        items[1] = itemJson("user_name", stringsUtil.bytes32ToString(_ownerName), false);
        items[2] = itemJson("certificate_uuid", stringsUtil.uuidToString(_certificateUUID), false);
        items[3] = itemJson("effective_date", stringsUtil.uintToString(_effectiveDate), true);
        coiSummary = wrapJsonObject("".toSlice().join(items));
    }

    function getCoisOfBroker(uint _brokerId) external view returns (string json) {
        address addressCoi = obtainControllerContract("coi");
        strings.slice[] memory objects = new strings.slice[](100);
        uint numCertificates;
        uint last;
        numCertificates = Coi(addressCoi).getNumCertificates();
        for(uint i = 1; i <= numCertificates; i++) {
            if(Coi(addressCoi).isCoiOfBroker(i, _brokerId)){
                objects[i*2] = getSummaryOfCoiForBroker(i).toSlice();
                objects[(i*2)+1] = ",".toSlice();
                last = (i*2)+1;
            }
        }
        objects[last] = "".toSlice();
        json = wrapObjectInArray("".toSlice().join(objects));
    }

    function getSummaryOfCoiForOwner(uint _certificateNumber) internal view returns (string coiSummary) {
        address addressCoi = obtainControllerContract("coi");
        address user = obtainControllerContract("user");
        uint _brokerId;
        bytes32 _brokerName;
        uint _effectiveDate;
        bytes16 _certificateUUID;

        (_certificateUUID, , _brokerId, _effectiveDate) = Coi(addressCoi).getCoi(_certificateNumber);
        (_brokerName, , ,) = User(user).getBroker(_brokerId);
        strings.slice[] memory items = new strings.slice[](3);
        items[0] = itemJson("broker_name", stringsUtil.bytes32ToString(_brokerName), false);
        items[1] = itemJson("certificate_uuid", stringsUtil.uuidToString(_certificateUUID), false);
        items[2] = itemJson("effective_date", stringsUtil.uintToString(_effectiveDate), true);
        coiSummary = wrapJsonObject("".toSlice().join(items));
    }

    function getCoisOfOwner(uint _ownerId) external view returns (string json) {
        address user = obtainControllerContract("user");
        strings.slice[] memory objects = new strings.slice[](40);
        uint numCertificates;
        uint[20] memory certificates;
        uint last;
        (certificates, numCertificates) = User(user).getOwnerCertificates(_ownerId);
        for(uint i = 0; i < numCertificates; i++) {
            objects[i*2] = getSummaryOfCoiForOwner(certificates[i]).toSlice();
            objects[(i*2)+1] = ",".toSlice();
            last = (i*2)+1;
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
