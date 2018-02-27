pragma solidity ^0.4.4;

contract DougEnabled {
    address DOUG;

    function setDougAddress(address dougAddress) public returns (bool) {
        if(DOUG != 0x0 && msg.sender != DOUG)
            return false;
        DOUG = dougAddress;
        return true;
    }

    function remove() public {
        if(msg.sender == DOUG){
            selfdestruct(DOUG);
        }
    }

    function getDougAddress() public view returns (address) {
        return DOUG;
    }
}
