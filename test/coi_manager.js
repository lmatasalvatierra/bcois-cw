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
  });

  describe("Certificate", function() {
    it("should create coi with given details", async function() {
      // COI Number 1
      await manager.createCoi(web3.fromAscii("TestCreate@cosa.com"),  timeNow, oneYearFromNow);
      let values = await manager.getCoi(1);
      // Active status = 0
      expect(values[0].toNumber()).to.equal(1);
      expect(values[1].toNumber()).to.equal(0);
      expect(values[2].toNumber()).to.equal(timeNow);
      expect(values[3].toNumber()).to.equal(oneYearFromNow);
    });

    it("should cancel coi of given policy", async function() {
      // COI Number 2
      await manager.createCoi(web3.fromAscii("TestCancel@cosa.com"), timeNow, oneYearFromNow);
      await manager.cancelCOI(1);
      let isCanceled = await manager.getCoiStatus(1);
      // Cancelled status = 1
      expect(isCanceled.toNumber()).to.equal(1);
    });

    it("should return a state of Active of a new COI", async function() {
      // COI Number 3
      await manager.createCoi(web3.fromAscii("testStatus@cosa.com"), timeNow, oneYearFromNow);
      let status = await manager.getCoiStatus(2);
      expect(status.toNumber()).to.equal(0);
    });

    it("should change a coi state to expired", async function() {
      let oneYearBeforeNow = timeNow - 31556926;
      let oneDayBeforeNow = timeNow - 86400;
      // COI Number 4
      await manager.createCoi(web3.fromAscii("TestExpired@cosa.com"), oneYearBeforeNow, oneDayBeforeNow);
      await manager.changeToExpired();

      let status = await manager.getCoiStatus(4);
      expect(status.toNumber()).to.equal(2);
    });

    it("should not change a coi state to expired", async function() {
      // COI Number 5
      await manager.createCoi(web3.fromAscii("TestNotExpired@cosa.com"), timeNow, oneYearFromNow);
      await manager.changeToExpired();
      let status = await manager.getCoiStatus(5);
      expect(status.toNumber()).to.equal(0);
    });

    it("should allow guest to read Coi from owner after allowing it", async function(){
      // COI Number 6
      await manager.createCoi(web3.fromAscii("Hola@cosa.com"), timeNow, oneYearFromNow);
      await manager.allowGuestToCheckCoi(web3.fromAscii("123456"), guest, {from: owner});
      let values = await manager.getCoi(6, {from: guest});
      expect(values[0].toNumber()).to.equal(6);
      expect(values[1].toNumber()).to.equal(0);
      expect(values[2].toNumber()).to.equal(timeNow);
      expect(values[3].toNumber()).to.equal(oneYearFromNow);
    });
  });

  describe("Policy", function() {
    before("should create Policy", async function() {
      await manager.createOwner(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("admin"), web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
      await manager.createPolicy(1, web3.fromAscii("Workers Comp"), timeNow, oneYearFromNow);
    });

    it("should get a Policy", async function() {
      // COI Number 7
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
      await manager.createPolicy(1, web3.fromAscii("BOP"), oneYearBeforeNow, oneDayBeforeNow);
      await manager.changePolicyToExpired();

      let status = await manager.getPolicyStatus(2);
      expect(status.toNumber()).to.equal(2);
    });

  });

  describe("Owner", function() {
    it("should be created correctly", async function() {
      await manager.createOwner(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("admin"), web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
      let values = await manager.getOwner(web3.fromAscii("Hola@cosa.com"));
      expect(web3.toAscii(values[0])).to.include("Hola@cosa.com");
      expect(web3.toAscii(values[1])).to.include("cosa");
      expect(web3.toAscii(values[2])).to.include("Alcala 21");
    });

    it("should have added a certificate to Owner", async function() {
      await manager.createOwner(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("admin"), web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
      await manager.addCertificate(web3.fromAscii("Hola@cosa.com"), 252342);
      let values = await manager.getOwner(web3.fromAscii("Hola@cosa.com"));
      expect(values[3][0].toNumber()).to.equal(252342);
    })

    it("should login correctly", async function() {
      await manager.createOwner(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("admin"), web3.fromAscii("cosa"), web3.fromAscii("Alcala 21"));
      let result = await manager.loginOwner(web3.fromAscii("Hola@cosa.com"), web3.fromAscii("admin"));
      expect(result).to.equal(true);
    });
  });
});
