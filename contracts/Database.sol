pragma solidity ^0.4.23;

import "./DougEnabled.sol";
import "./Doug.sol";

contract Database is DougEnabled {
  modifier senderIsController(bytes32 controller) {
      address _contractAddress = Doug(DOUG).getContract(controller);
      require (msg.sender == _contractAddress, "Sender is not the controller");
      _;
  }
}
