var COIManager = artifacts.require("./COIManager.sol");

module.exports = async function(callback) {
    var manager = await COIManager.deployed();
    let timeNow = Math.floor(Date.now() / 1000);
    let oneYearFromNow = timeNow + 31556926;
    try {
        await manager.createOwner(web3.fromAscii("Test5@Owner.com"), "admin", web3.fromAscii("Luis Miguel"), web3.fromAscii("Alcala 21"));
        await manager.createCarrier(web3.fromAscii("Test2@Carrier.com"), "admin", web3.fromAscii("CNA"));
        await manager.createOwner(web3.fromAscii("Test3@Owner.com"), "admin", web3.fromAscii("Roberto Carlos"), web3.fromAscii("Alcala 21"));
        await manager.createBroker(web3.fromAscii("Test4@Broker.com"), "admin", web3.fromAscii("Coverwallet"), web3.fromAscii("2128677475"), web3.fromAscii("Alcala 21"));
        await manager.createOwner(web3.fromAscii("Test5@Owner.com"), "admin", web3.fromAscii("Pedro Pablo"), web3.fromAscii("Alcala 21"));
        await manager.createPolicy(web3.fromAscii("Test5@Owner.com"), web3.fromAscii("Business Owners Policy"), timeNow, oneYearFromNow, 2);
        await manager.createPolicy(web3.fromAscii("Test5@Owner.com"), web3.fromAscii("General Liability"), timeNow, oneYearFromNow, 2);
        await manager.createPolicy(web3.fromAscii("Test5@Owner.com"), web3.fromAscii("Workers Compensation"), timeNow, oneYearFromNow, 2);
        await manager.createPolicy(web3.fromAscii("Test5@Owner.com"), web3.fromAscii("Business Owners Policy"), timeNow, oneYearFromNow, 2);
        await manager.createCoi("Test5@Owner.com", timeNow, 4, [1, 2]);
    } catch(e) {
        console.error(e);
    }

};
