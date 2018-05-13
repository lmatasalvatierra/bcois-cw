var COIManager = artifacts.require("./COIManager.sol");
var Coi = artifacts.require("./Coi.sol");
var Doug = artifacts.require("./Doug.sol");
var CoiDB = artifacts.require("./CoiDB.sol");
var User = artifacts.require("./User.sol");
var Policy = artifacts.require("./Policy.sol");
var OwnerDB = artifacts.require("./OwnerDB.sol");
var PolicyDB = artifacts.require("./PolicyDB.sol");
var CarrierDB = artifacts.require("./CarrierDB.sol");
var BrokerDB = artifacts.require("./BrokerDB.sol");
var UserDB = artifacts.require("./UserDB.sol");

module.exports = async function(callback) {
    var doug = await Doug.deployed();
    var manager = await COIManager.deployed();
    var coi = await Coi.deployed();
    var coiDb = await CoiDB.deployed();
    var user = await User.deployed();
    var ownerdb = await OwnerDB.deployed();
    var policy = await Policy.deployed();
    var policydb = await PolicyDB.deployed();
    var carrierdb = await CarrierDB.deployed();
    var brokerdb = await BrokerDB.deployed();
    var userdb = await UserDB.deployed();

    await doug.addContract("coiManager", manager.address);
    await doug.addContract("coi", coi.address);
    await doug.addContract("coiDB", coiDb.address);
    await doug.addContract("user", user.address);
    await doug.addContract("ownerDB", ownerdb.address);
    await doug.addContract("policy", policy.address);
    await doug.addContract("policyDB", policydb.address);
    await doug.addContract("carrierDB", carrierdb.address);
    await doug.addContract("brokerDB", brokerdb.address);
    await doug.addContract("userDB", userdb.address);
};
 
