var Permission = artifacts.require("./Permission.sol");
var PermissionDB = artifacts.require("./PermissionDB.sol");
var COIManager = artifacts.require("./COIManager.sol");
var Carrier = artifacts.require("./Carrier.sol");
var Doug = artifacts.require("./Doug.sol");
var CarrierDB = artifacts.require("./CarrierDB.sol");

module.exports = async function(callback) {
  var doug = await Doug.deployed();
  console.log("Doug: " + doug.address);
  var manager = await COIManager.deployed();
  console.log("COIManager: " + manager.address);
  var carrier = await Carrier.deployed();
  console.log("Carrier: " + carrier.address);
  var carrierdb = await CarrierDB.deployed();
  console.log("CarrierDB: " + carrierdb.address);
  var perm = await Permission.deployed();
  console.log("Permission: " + perm.address);
  var permdb = await PermissionDB.deployed();
  console.log("PermissionDB: " + permdb.address);
  await doug.addContract("coiManager", manager.address);
  await doug.addContract("carrier", carrier.address);
  await doug.addContract("carrierDB", carrierdb.address);
  await doug.addContract("perm", perm.address);
  await doug.addContract("permDB", permdb.address);
};
