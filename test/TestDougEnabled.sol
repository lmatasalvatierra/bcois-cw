pragma solidity ^0.4.2;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DougEnabled.sol";

contract TestDougEnabled {

  function testSetsDougAddress() public {
    DougEnabled dougEnabled = DougEnabled(DeployedAddresses.DougEnabled());
    bool result = dougEnabled.setDougAddress(tx.origin);

    Assert.equal(result, true, "Address should be valid");
  }

  /*function testInitialBalanceWithNewMetaCoin() public {
    MetaCoin meta = new MetaCoin();

    uint expected = 10000;

    Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  }*/

}
