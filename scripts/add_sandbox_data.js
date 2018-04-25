var COIManager = artifacts.require("./COIManager.sol");

module.exports = async function(callback) {
    var manager = await COIManager.deployed();
    let timeNow = Math.floor(Date.now() / 1000);
    let oneYearFromNow = timeNow + 31556926;
    try {
        await manager.createOwner(web3.fromAscii("Test@Owner.com"), "admin", web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
        await manager.createCarrier(web3.fromAscii("TestCreation@Carrier.com"), "admin", web3.fromAscii("CNA"));
        await manager.createOwner(web3.fromAscii("CertificateTest@cosa.com"), "admin", web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
        await manager.createBroker(web3.fromAscii("TestCreation@Broker.com"), "admin", web3.fromAscii("Coverwallet"), web3.fromAscii("2128677475"), web3.fromAscii("Alcala 21"));
        await manager.createCoi("CertificateTest@cosa.com");
        await manager.createOwner(web3.fromAscii("Hola@cosa.com"), "admin", web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
        await manager.createPolicy(1, web3.fromAscii("Workers Comp"), timeNow, oneYearFromNow, 1);
        await manager.addPolicy(1, 1)
        await manager.createPolicy(1, web3.fromAscii("Business Owners Policy"), timeNow, oneYearFromNow, 1);
        await manager.addPolicy(1, 2)
    } catch(e) {
        console.error(e);
    }

};
