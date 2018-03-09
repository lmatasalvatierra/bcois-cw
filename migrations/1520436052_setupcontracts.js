var Permission = artifacts.require("./Permission.sol");
var PermissionDB = artifacts.require("./PermissionDB.sol");
var COIManager = artifacts.require("./COIManager.sol");
var Coi = artifacts.require("./Coi.sol");
var Doug = artifacts.require("./Doug.sol");
var CoiDB = artifacts.require("./CoiDB.sol");

module.exports = async function(deployer) {
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
};
