var Doug = artifacts.require("./Doug.sol");
var DataHelper = artifacts.require("./DataHelper.sol");
var DougEnabled = artifacts.require("./DougEnabled.sol");
var CarrierDB = artifacts.require("./CarrierDB.sol");
var Carrier = artifacts.require("./Carrier.sol");
var COIManager = artifacts.require("./COIManager.sol");



module.exports = function(deployer) {
  deployer.deploy(Doug);
  deployer.deploy(DataHelper);
  deployer.deploy(DougEnabled);
  deployer.deploy(CarrierDB);
  deployer.deploy(Carrier);
  deployer.deploy(COIManager);
};
