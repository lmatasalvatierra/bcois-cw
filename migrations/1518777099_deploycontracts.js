var Doug = artifacts.require("./Doug.sol");
var DataHelper = artifacts.require("./DataHelper.sol");
var DougEnabled = artifacts.require("./DougEnabled.sol");
var CoiDB = artifacts.require("./CoiDB.sol");
var Coi = artifacts.require("./Coi.sol");
var COIManager = artifacts.require("./COIManager.sol");
var Permission = artifacts.require("./Permission.sol");
var PermissionDB = artifacts.require("./PermissionDB.sol");
var DateTime = artifacts.require("./DateTime.sol");



module.exports = function(deployer) {
  deployer.deploy(Doug);
  deployer.deploy(DataHelper);
  deployer.deploy(DougEnabled);
  deployer.deploy(DateTime);
  deployer.link(DateTime, CoiDB);
  deployer.deploy(CoiDB);
  deployer.deploy(Coi);
  deployer.deploy(COIManager);
  deployer.deploy(Permission);
  deployer.deploy(PermissionDB);
};
