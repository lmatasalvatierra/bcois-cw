var Permission = artifacts.require("./Permission.sol");
var PermissionDB = artifacts.require("./PermissionDB.sol");
var COIManager = artifacts.require("./COIManager.sol");
var Coi = artifacts.require("./Coi.sol");
var Doug = artifacts.require("./Doug.sol");
var CoiDB = artifacts.require("./CoiDB.sol");
var expect = require("chai").expect;

contract('COIManager', function(accounts) {

  beforeEach('setup manager', async function () {
    var doug = await Doug.deployed();
    var manager = await COIManager.deployed();
    var coi = await Coi.deployed();
    var coiDb = await CoiDB.deployed();
    var perm = await Permission.deployed();
    var permdb = await PermissionDB.deployed();
    await doug.addContract("coiManager", manager.address);
    await doug.addContract("coi", coi.address);
    await doug.addContract("coiDB", coiDb.address);
    await doug.addContract("perm", perm.address);
    await doug.addContract("permDB", permdb.address);
    await manager.setPermission(accounts[1], web3.fromDecimal('2'));
  });

  describe("CreateCoi", function() {
    it("should create coi with given details", async function() {
      let manager = await COIManager.deployed();
      let creation = await manager.createCoi(web3.fromAscii("123456"), accounts[1], accounts[2], web3.fromAscii("12/02/2018"), web3.fromAscii("12/02/2019"), {from: accounts[1]});
      let values = await manager.getCoi.call(web3.fromAscii("123456"));
      expect(values[0]).to.equal(accounts[1]);
      expect(values[1]).to.equal(accounts[2]);
      expect(values[2].toNumber()).to.equal(0);
      expect(web3.toAscii(values[3])).to.include("12/02/2018");
      expect(web3.toAscii(values[4])).to.include("12/02/2019");
    });
  });

  describe("cancelCoi", function() {
    it("should cancel coi of given policy", async function() {
      let manager = await COIManager.deployed();
      await manager.createCoi(web3.fromAscii("123456"), accounts[1], accounts[2], web3.fromAscii("12/02/2018"), web3.fromAscii("12/02/2019"), {from: accounts[1]});
      await manager.cancelCOI(web3.fromAscii("123456"), {from: accounts[1]});
      let isCanceled = await manager.getCoiStatus(web3.fromAscii("123456"));
      expect(isCanceled.toNumber()).to.equal(1);
    });
  });

  describe("setPermission", function() {
    it("should set permission of Agency", async function() {
      let manager = await COIManager.deployed();
      await manager.setPermission(accounts[1], 2);
    });
  });

});
