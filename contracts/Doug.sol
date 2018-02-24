pragma solidity ^0.4.4;
import "./DougEnabled.sol";

contract Doug {
    address owner;

    mapping (bytes32 => address) contracts;

    function Doug() public  {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    function addContract(bytes32 name, address addr) isOwner public returns (bool) {
        bool doesntHaveDougAddress = DougEnabled(addr).setDougAddress(address(this));
        if(!doesntHaveDougAddress)
            return false;
        contracts[name] = addr;
        return true;
    }

    function removeContract(bytes32 name) isOwner public returns (bool) {
        if(contracts[name] == 0x0)
            return false;
        contracts[name] = 0x0;
        return true;
    }

    function getContract(bytes32 name) public view returns (address) {
        return contracts[name];
    }

    function remove() isOwner public {
        selfdestruct(owner);
    }
}
