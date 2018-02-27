pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DougEnabled.sol";

contract TestDougEnabled {

  function testSetsDougAddress() public {
    DougEnabled dougEnabled = DougEnabled(DeployedAddresses.DougEnabled());

    dougEnabled.setDougAddress(msg.sender);
    address dougAddress = dougEnabled.getDougAddress();

    Assert.equal(msg.sender, dougAddress, "Address should be valid");
  }
  
}
