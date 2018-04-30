const web3Instance = require('web3')
var Doug = artifacts.require("./Doug.sol");
var DataHelper = artifacts.require("./libraries/DataHelper.sol");
var DougEnabled = artifacts.require("./DougEnabled.sol");
var CoiDB = artifacts.require("./databases/CoiDB.sol");
var Coi = artifacts.require("./controllers/Coi.sol");
var COIManager = artifacts.require("./COIManager.sol");
var DateTime = artifacts.require("./libraries/DateTime.sol");
var User = artifacts.require("./controllers/User.sol");
var OwnerDB = artifacts.require("./databases/OwnerDB.sol");
var Policy = artifacts.require("./controllers/Policy.sol");
var PolicyDB = artifacts.require("./databases/PolicyDB.sol");
var CarrierDB = artifacts.require("./databases/CarrierDB.sol");
var BrokerDB = artifacts.require("./databases/BrokerDB.sol");
var stringsUtil = artifacts.require("./libraries/stringsUtil.sol");
var expect = require("chai").expect;

contract('COIManager', function(accounts) {
  var doug, manager, coi, coiDb, user, ownerdb, policy, policydb, carriedb, brokerdb;
  let timeNow = Math.floor(Date.now() / 1000);
  let oneYearFromNow = timeNow + 31556926;
  let agency = accounts[1];
  let owner = accounts[2];
  let guest = accounts[6];

  beforeEach('setup manager', async function () {
    doug = await Doug.new();
    manager = await COIManager.new();
    coi = await Coi.new();
    coiDb = await CoiDB.new();
    user = await User.new();
    ownerdb = await OwnerDB.new();
    policy = await Policy.new();
    policydb = await PolicyDB.new();
    carrierdb = await CarrierDB.new();
    brokerdb = await BrokerDB.new();

    await doug.addContract("coiManager", manager.address);
    await doug.addContract("coi", coi.address);
    await doug.addContract("coiDB", coiDb.address);
    await doug.addContract("user", user.address);
    await doug.addContract("ownerDB", ownerdb.address);
    await doug.addContract("policy", policy.address);
    await doug.addContract("policyDB", policydb.address);
    await doug.addContract("carrierDB", carrierdb.address);
    await doug.addContract("brokerDB", brokerdb.address);

    await manager.createOwner(web3.fromAscii("Test@Owner.com"), "admin", web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
    await manager.createCarrier(web3.fromAscii("TestCreation@Carrier.com"), "admin", web3.fromAscii("CNA"));
    await manager.createBroker(web3.fromAscii("TestCreation@Broker.com"), "admin", web3.fromAscii("Coverwallet"), web3.fromAscii("2128677475"), web3.fromAscii("Alcala 21"));
  });

  describe("Owner", function() {
    it("should login correctly", async function() {
      let result = await manager.login(web3.fromAscii("Test@Owner.com"), web3Instance.utils.keccak256("admin"));
      expect(result[0].toNumber()).to.equal(1);
      expect(result[1].toNumber()).to.equal(0);
    });
  });

  describe("Carrier", function() {
    it("should login correctly", async function() {
      let result = await manager.login(web3.fromAscii("TestCreation@Carrier.com"), web3Instance.utils.keccak256("admin"));
      expect(result[0].toNumber()).to.equal(2);
      expect(result[1].toNumber()).to.equal(1);
    });
  });

  describe("Broker", function() {
    it("should login correctly", async function() {
      let result = await manager.login(web3.fromAscii("TestCreation@Broker.com"), web3Instance.utils.keccak256("admin"));
      expect(result[0].toNumber()).to.equal(3);
      expect(result[1].toNumber()).to.equal(2);
    });
  });


});
