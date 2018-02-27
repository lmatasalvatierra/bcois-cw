pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Doug.sol";

contract TestDoug {

  function testAddContract() public {
    Doug doug = Doug(DeployedAddresses.Doug());

    doug.addContract("test", msg.sender);
    address dougAddress = Doug(doug).getContract("test");

    Assert.equal(msg.sender, dougAddress, "Address should be valid");
  }

}
