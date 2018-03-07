var Doug = artifacts.require("./Doug.sol");
var DataHelper = artifacts.require("./DataHelper.sol");
var DougEnabled = artifacts.require("./DougEnabled.sol");
var CoiDB = artifacts.require("./CoiDB.sol");
var Coi = artifacts.require("./Coi.sol");
var COIManager = artifacts.require("./COIManager.sol");



module.exports = function(deployer) {
  deployer.deploy(Doug);
  deployer.deploy(DataHelper);
  deployer.deploy(DougEnabled);
  deployer.deploy(CoiDB);
  deployer.deploy(Coi);
  deployer.deploy(COIManager);
};
