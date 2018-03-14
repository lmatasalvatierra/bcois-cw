var Permission = artifacts.require("./Permission.sol");
var PermissionDB = artifacts.require("./PermissionDB.sol");
var COIManager = artifacts.require("./COIManager.sol");
var Coi = artifacts.require("./Coi.sol");
var Doug = artifacts.require("./Doug.sol");
var CoiDB = artifacts.require("./CoiDB.sol");
var expect = require("chai").expect;

contract('COIManager', function(accounts) {
  var doug, manager, coi, coiDb, perm, permdb;
  let timeNow = Math.floor(Date.now() / 1000);
  let oneYearFromNow = timeNow + 31556926;

  beforeEach('setup manager', async function () {
    doug = await Doug.deployed();
    manager = await COIManager.deployed();
    coi = await Coi.deployed();
    coiDb = await CoiDB.deployed();
    perm = await Permission.deployed();
    permdb = await PermissionDB.deployed();
    await doug.addContract("coiManager", manager.address);
    await doug.addContract("coi", coi.address);
    await doug.addContract("coiDB", coiDb.address);
    await doug.addContract("perm", perm.address);
    await doug.addContract("permDB", permdb.address);
    await manager.setPermission(accounts[1], web3.fromDecimal('2'));
  });

  describe("CreateCoi", function() {
    it("should create coi with given details", async function() {
      await manager.createCoi(web3.fromAscii("123456"), accounts[1], accounts[2], timeNow, oneYearFromNow, {from: accounts[1]});
      let values = await manager.getCoi.call(web3.fromAscii("123456"));
      expect(values[0]).to.equal(accounts[1]);
      expect(values[1]).to.equal(accounts[2]);
      // Active status = 0
      expect(values[2].toNumber()).to.equal(0);
      expect(values[3].toNumber()).to.equal(timeNow);
      expect(values[4].toNumber()).to.equal(oneYearFromNow);
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

  describe("setPermission", function() {
    it("should set permission of Agency", async function() {
      await manager.setPermission(accounts[1], 2);
    });
  });

});
