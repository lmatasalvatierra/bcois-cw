var COIManager = artifacts.require("./COIManager.sol");

module.exports = async function(callback) {
    var manager = await COIManager.deployed();
    try {
        await manager.createOwner(web3.fromAscii("Test@Owner.com"), web3.fromAscii("admin"), web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
        await manager.createCarrier(web3.fromAscii("TestCreation@Carrier.com"), web3.fromAscii("admin"), web3.fromAscii("CNA"));
        await manager.createOwner(web3.fromAscii("CertificateTest@cosa.com"), web3.fromAscii("admin"), web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
        await manager.createCoi("CertificateTest@cosa.com");
        await manager.createOwner(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("admin"), web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
        await manager.createPolicy(1, web3.fromAscii("Workers Comp"), timeNow, oneYearFromNow, 1);
    } catch(e) {
        console.error(e);
    }

};
