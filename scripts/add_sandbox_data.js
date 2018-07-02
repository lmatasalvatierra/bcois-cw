var COIManager = artifacts.require("./COIManager.sol");
const uuidv4 = require('uuid/v4');
const uuidToHex = require('uuid-to-hex');

module.exports = async function(callback) {
    var manager = await COIManager.deployed();
    let timeNow = Math.floor(Date.now() / 1000);
    let oneYearFromNow = timeNow + 31556926;
    try {
        const owner1UUID = uuidToHex(uuidv4(), true);
        const owner2UUID = uuidToHex(uuidv4(), true);
        const owner3UUID = uuidToHex(uuidv4(), true);
        const carrierUUID = uuidToHex(uuidv4(), true);
        const brokerUUID = uuidToHex(uuidv4(), true);
        await manager.createOwner(web3.fromAscii("Test1@Owner.com"), web3.sha3("admin"), web3.fromAscii("Luis Miguel"), web3.fromAscii("Alcala 21"), owner1UUID);
        await manager.createCarrier(web3.fromAscii("Test2@Carrier.com"), web3.sha3("admin"), web3.fromAscii("CNA"), carrierUUID);
        await manager.createOwner(web3.fromAscii("Test3@Owner.com"), web3.sha3("admin"), web3.fromAscii("Roberto Carlos"), web3.fromAscii("Alcala 21"), owner2UUID);
        await manager.createBroker(web3.fromAscii("Test4@Broker.com"), web3.sha3("admin"), web3.fromAscii("Coverwallet"), web3.fromAscii("2128677475"), web3.fromAscii("Alcala 21"), brokerUUID);
        await manager.createOwner(web3.fromAscii("Test5@Owner.com"), web3.sha3("admin"), web3.fromAscii("Pedro Pablo"), web3.fromAscii("Alcala 21"), owner3UUID);
        const policy1UUID = uuidToHex(uuidv4(), true);
        const policy2UUID = uuidToHex(uuidv4(), true);
        await manager.createPolicy(web3.fromAscii("Test5@Owner.com"), web3.fromAscii("Business Owners Policy"), timeNow, oneYearFromNow, carrierUUID, policy1UUID);
        await manager.createPolicy(web3.fromAscii("Test5@Owner.com"), web3.fromAscii("General Liability"), timeNow, oneYearFromNow, carrierUUID, policy2UUID);
        await manager.createPolicy(web3.fromAscii("Test1@Owner.com"), web3.fromAscii("Workers Compensation"), timeNow, oneYearFromNow, carrierUUID, uuidToHex(uuidv4(), true));
        await manager.createPolicy(web3.fromAscii("Test1@Owner.com"), web3.fromAscii("Business Owners Policy"), timeNow, oneYearFromNow, carrierUUID, uuidToHex(uuidv4(), true));
        await manager.createCoi("Test5@Owner.com", timeNow, brokerUUID, [policy1UUID, policy2UUID], uuidToHex(uuidv4(), true));
    } catch(e) {
        console.error(e);
    }

};
