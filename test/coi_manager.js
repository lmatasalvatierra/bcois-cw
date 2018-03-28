var Permission = artifacts.require("./Permission.sol");
var PermissionDB = artifacts.require("./PermissionDB.sol");
var COIManager = artifacts.require("./COIManager.sol");
var Coi = artifacts.require("./Coi.sol");
var Doug = artifacts.require("./Doug.sol");
var CoiDB = artifacts.require("./CoiDB.sol");
var User = artifacts.require("./User.sol");
var Policy = artifacts.require("./Policy.sol")
var UserDB = artifacts.require("./UserDB.sol");
var OwnerDB = artifacts.require("./OwnerDB.sol");
var PolicyDB = artifacts.require("./PolicyDB.sol");
var CarrierDB = artifacts.require("./CarrierDB.sol");
var expect = require("chai").expect;

contract('COIManager', function(accounts) {
  var doug, manager, coi, coiDb, perm, permdb;
  let timeNow = Math.floor(Date.now() / 1000);
  let oneYearFromNow = timeNow + 31556926;
  let agency = accounts[1];
  let owner = accounts[2];
  let guest = accounts[6];

  before('setup manager', async function () {
    doug = await Doug.deployed();
    manager = await COIManager.deployed();
    coi = await Coi.deployed();
    coiDb = await CoiDB.deployed();
    perm = await Permission.deployed();
    permdb = await PermissionDB.deployed();
    user = await User.deployed();
    userdb = await UserDB.deployed();
    ownerdb = await OwnerDB.deployed();
    policy = await Policy.deployed();
    policydb = await PolicyDB.deployed();
    carrierdb = await CarrierDB.deployed();

    await doug.addContract("coiManager", manager.address);
    await doug.addContract("coi", coi.address);
    await doug.addContract("coiDB", coiDb.address);
    await doug.addContract("perm", perm.address);
    await doug.addContract("permDB", permdb.address);
    await doug.addContract("user", user.address);
    await doug.addContract("userDB", userdb.address);
    await doug.addContract("ownerDB", ownerdb.address);
    await doug.addContract("policy", policy.address);
    await doug.addContract("policyDB", policydb.address);
    await doug.addContract("carrierDB", carrierdb.address);
  });

  describe("Certificate", function() {
    before("should Create COI and Owner", async function() {
      await manager.createOwner(web3.fromAscii("CertificateTest@cosa.com"), web3.fromAscii("admin"), web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
      await manager.createCoi("CertificateTest@cosa.com");
    });

    it("should create coi with given details", async function() {
      let values = await manager.getCoi(1);
      expect(values[0].toNumber()).to.equal(1);
      expect(values[1].toNumber()).to.equal(1);
    });

    it("add Policy to certificate", async function() {
      await manager.createPolicy(1, web3.fromAscii("Workers Comp"), timeNow, oneYearFromNow, 1);
      await manager.addPolicy(1, 1)
      let result = await manager.getPoliciesOfCoi(1);
      let values = await manager.getPolicy(result[0].toNumber());
      expect(values[0].toNumber()).to.equal(1);
      expect(values[1].toNumber()).to.equal(1);
      expect(web3.toAscii(values[2])).to.include("Workers Comp");
      expect(values[3].toNumber()).to.equal(0);
      expect(values[4].toNumber()).to.equal(timeNow);
      expect(values[5].toNumber()).to.equal(oneYearFromNow);
    });
  });

  describe("Policy", function() {
    before("should create Policy", async function() {
      await manager.createCarrier(web3.fromAscii("TestCreation@Carrier.com"), web3.fromAscii("admin"), web3.fromAscii("CNA"));
      await manager.createOwner(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("admin"), web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
      await manager.createPolicy(1, web3.fromAscii("Workers Comp"), timeNow, oneYearFromNow, 1);
    });

    it("should get a Policy", async function() {
      let values = await manager.getPolicy(1);
      expect(values[0].toNumber()).to.equal(1);
      expect(values[1].toNumber()).to.equal(1);
      expect(web3.toAscii(values[2])).to.include("Workers Comp");
      expect(values[3].toNumber()).to.equal(0);
      expect(values[4].toNumber()).to.equal(timeNow);
      expect(values[5].toNumber()).to.equal(oneYearFromNow);
    });

    it("should cancel a Policy", async function() {
      await manager.cancelPolicy(1);
      let isCanceled = await manager.getPolicyStatus(1);
      // Cancelled status = 1
      expect(isCanceled.toNumber()).to.equal(1);
    });

    it("should change a Policy state to expired", async function() {
      let oneYearBeforeNow = timeNow - 31556926;
      let oneDayBeforeNow = timeNow - 86400;
      await manager.createPolicy(1, web3.fromAscii("BOP"), oneYearBeforeNow, oneDayBeforeNow, 1);
      await manager.changePolicyToExpired();

      let status = await manager.getPolicyStatus(3);
      expect(status.toNumber()).to.equal(2);
    });

  });

  describe("Owner", function() {
    before("should Create Owner", async function() {
      await manager.createOwner(web3.fromAscii("Test@Owner.com"), web3.fromAscii("admin"), web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
    });

    it("should be created correctly", async function() {
      let values = await manager.getOwner(web3.fromAscii("Test@Owner.com"));
      expect(web3.toAscii(values[0])).to.include("Test@Owner.com");
      expect(web3.toAscii(values[1])).to.include("cosa");
      expect(web3.toAscii(values[2])).to.include("Alcala 21");
    });

    it("should have added a certificate to Owner", async function() {
      await manager.addCertificate(web3.fromAscii("Test@Owner.com"), 252342);
      let values = await manager.getOwner(web3.fromAscii("Test@Owner.com"));
      expect(values[3][0].toNumber()).to.equal(252342);
    })

    it("should login correctly", async function() {
      let result = await manager.loginOwner(web3.fromAscii("Test@Owner.com"), web3.fromAscii("admin"));
      expect(result).to.equal(true);
    });
  });

  describe("Carrier", function() {
    before("should Create Carrier", async function() {
      await manager.createCarrier(web3.fromAscii("TestCreation@Carrier.com"), web3.fromAscii("admin"), web3.fromAscii("CNA"));
    });

    it("should get correctly", async function() {
      let values = await manager.getCarrier(web3.fromAscii("TestCreation@Carrier.com"));
      expect(web3.toAscii(values[2])).to.include("TestCreation@Carrier.com");
      expect(values[1].toNumber()).to.equal(5);
      expect(web3.toAscii(values[0])).to.include("CNA");
    });

    it("should login correctly", async function() {
      let result = await manager.loginCarrier(web3.fromAscii("TestCreation@Carrier.com"), web3.fromAscii("admin"));
      expect(result).to.equal(true);
    });
  });
});
