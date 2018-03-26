var Permission = artifacts.require("./Permission.sol");
var PermissionDB = artifacts.require("./PermissionDB.sol");
var COIManager = artifacts.require("./COIManager.sol");
var Coi = artifacts.require("./Coi.sol");
var Doug = artifacts.require("./Doug.sol");
var CoiDB = artifacts.require("./CoiDB.sol");
var User = artifacts.require("./User.sol");
var UserDB = artifacts.require("./UserDB.sol");
var OwnerDB = artifacts.require("./OwnerDB.sol");
var expect = require("chai").expect;

contract('COIManager', function(accounts) {
  var doug, manager, coi, coiDb, perm, permdb;
  let timeNow = Math.floor(Date.now() / 1000);
  let oneYearFromNow = timeNow + 31556926;
  let agency = accounts[1];
  let owner = accounts[2];
  let guest = accounts[6];

  beforeEach('setup manager', async function () {
    doug = await Doug.deployed();
    manager = await COIManager.deployed();
    coi = await Coi.deployed();
    coiDb = await CoiDB.deployed();
    perm = await Permission.deployed();
    permdb = await PermissionDB.deployed();
    user = await User.deployed();
    userdb = await UserDB.deployed();
    ownerdb = await OwnerDB.deployed();

    await doug.addContract("coiManager", manager.address);
    await doug.addContract("coi", coi.address);
    await doug.addContract("coiDB", coiDb.address);
    await doug.addContract("perm", perm.address);
    await doug.addContract("permDB", permdb.address);
    await doug.addContract("user", user.address);
    await doug.addContract("userDB", userdb.address);
    await doug.addContract("ownerDB", ownerdb.address);
  });

  describe("CreateCoi", function() {
    it("should create coi with given details", async function() {
      await manager.createCoi(web3.fromAscii("123456"), agency, owner, timeNow, oneYearFromNow, {from: agency});
      let values = await manager.getCoi(web3.fromAscii("123456"), {from: owner});
      // Active status = 0
      expect(values[0].toNumber()).to.equal(0);
      expect(values[1].toNumber()).to.equal(timeNow);
      expect(values[2].toNumber()).to.equal(oneYearFromNow);
    });
  });

  describe("cancelCoi", function() {
    it("should cancel coi of given policy", async function() {
      await manager.createCoi(web3.fromAscii("123456"), accounts[1], accounts[2], timeNow, oneYearFromNow, {from: accounts[1]});
      await manager.cancelCOI(web3.fromAscii("123456"), {from: accounts[1]});
      let isCanceled = await manager.getCoiStatus(web3.fromAscii("123456"));
      // Cancelled status = 1
      expect(isCanceled.toNumber()).to.equal(1);
    });
  });

  describe("getCoiStatus", function () {
    it("should return a state of Active of a new COI", async function() {
      await manager.createCoi(web3.fromAscii("123456"), accounts[1], accounts[2], timeNow, oneYearFromNow, {from: accounts[1]});
      let status = await manager.getCoiStatus(web3.fromAscii("123456"));
      expect(status.toNumber()).to.equal(0);
    })
  });

  describe("changeToExpired", function() {
    it("should change a coi state to expired", async function() {
      let oneYearBeforeNow = timeNow - 31556926;
      let oneDayBeforeNow = timeNow - 86400;
      await manager.createCoi(web3.fromAscii("123456"), accounts[1], accounts[2], oneYearBeforeNow, oneDayBeforeNow, {from: accounts[1]});
      await manager.changeToExpired();
      let status = await manager.getCoiStatus(web3.fromAscii("123456"));
      expect(status.toNumber()).to.equal(2);
    });

    it("should not change a coi state to expired", async function() {
      await manager.createCoi(web3.fromAscii("123456"), accounts[1], accounts[2], timeNow, oneYearFromNow, {from: accounts[1]});
      await manager.changeToExpired();
      let status = await manager.getCoiStatus(web3.fromAscii("123456"));
      expect(status.toNumber()).to.equal(0);
    });
  });

  describe("allowGuestToCheckCoi", function() {
    it("should allow guest to read Coi from owner after allowing it", async function(){
      await manager.createCoi(web3.fromAscii("123456"), agency, owner, timeNow, oneYearFromNow, {from: agency});
      await manager.allowGuestToCheckCoi(web3.fromAscii("123456"), guest, {from: owner});
      let values = await manager.getCoi(web3.fromAscii("123456"), {from: guest});
      expect(values[0].toNumber()).to.equal(0);
      expect(values[1].toNumber()).to.equal(timeNow);
      expect(values[2].toNumber()).to.equal(oneYearFromNow);
    });

    it("should allow guest to read Coi from owner after allowing it", async function(){
      await manager.createCoi(web3.fromAscii("123456"), agency, owner, timeNow, oneYearFromNow, {from: agency});
      let result = await manager.allowGuestToCheckCoi(web3.fromAscii("123456"), guest, {from: guest});
      expect(result.logs[0].args.statusCode.c[0]).to.equal(101);
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
