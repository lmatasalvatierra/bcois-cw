var COIManager = artifacts.require("./COIManager.sol");

module.exports = async function(callback) {
    var manager = await COIManager.deployed();
    let timeNow = Math.floor(Date.now() / 1000);
    let oneYearFromNow = timeNow + 31556926;
    try {
        await manager.createOwner(web3.fromAscii("Test@Owner.com"), "admin", web3.fromAscii("DY"), web3.fromAscii("Alcala 21"));
        await manager.createCarrier(web3.fromAscii("TestCreation@Carrier.com"), "admin", web3.fromAscii("CNA"));
        await manager.createOwner(web3.fromAscii("CertificateTest@cosa.com"), "admin", web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
        await manager.createBroker(web3.fromAscii("TestCreation@Broker.com"), "admin", web3.fromAscii("Coverwallet"), web3.fromAscii("2128677475"), web3.fromAscii("Alcala 21"));
        await manager.createOwner(web3.fromAscii("Hola@cosa.com"), "admin", web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
        await manager.createPolicy(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("BOP"), timeNow, oneYearFromNow, 2);
        await manager.createPolicy(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("GEneral Liability"), timeNow, oneYearFromNow, 2);
        await manager.createPolicy(web3.fromAscii("CertificateTest@cosa.com"), web3.fromAscii("Workers Comp"), timeNow, oneYearFromNow, 2);
        await manager.createPolicy(web3.fromAscii("CertificateTest@cosa.com"), web3.fromAscii("Business Owners Policy"), timeNow, oneYearFromNow, 2);
    } catch(e) {
        console.error(e);
    }

};
