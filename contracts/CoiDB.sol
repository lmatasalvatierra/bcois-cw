pragma solidity ^0.4.4;
import "./DougEnabled.sol";
import "./Doug.sol";
import "./DataHelper.sol";
import "./DateTime.sol";

contract CoiDB is DougEnabled{
    uint numCertificates;
    mapping (uint => DataHelper.CoI) cois;

    modifier senderIsController() {
        address _contractAddress = Doug(DOUG).getContract("coi");
        require (msg.sender == _contractAddress);
        _;
    }

    function createCoi(uint _ownerId) senderIsController public returns (uint id)
    {
        numCertificates++;
        DataHelper.CoI storage coi = cois[numCertificates];
        coi.certificateNumber = numCertificates;
        coi.ownerId = _ownerId;
        return numCertificates;
    }

    function getCoi(uint certificateNumber) senderIsController public view returns(uint, uint)
    {
        DataHelper.CoI storage coi = cois[certificateNumber];
        return (coi.certificateNumber, coi.ownerId);
    }
}
