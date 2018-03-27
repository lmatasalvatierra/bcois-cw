pragma solidity ^0.4.4;

import "./Database.sol";
import "./DataHelper.sol";

contract CoiDB is Database {
    uint numCertificates;
    mapping (uint => DataHelper.CoI) cois;

    function createCoi(uint _ownerId) senderIsController("coi") public returns (uint id)
    {
        numCertificates++;
        DataHelper.CoI storage coi = cois[numCertificates];
        coi.certificateNumber = numCertificates;
        coi.ownerId = _ownerId;
        return numCertificates;
    }

    function getCoi(uint certificateNumber) senderIsController("coi") public view returns(uint, uint)
    {
        DataHelper.CoI storage coi = cois[certificateNumber];
        return (coi.certificateNumber, coi.ownerId);
    }
}
