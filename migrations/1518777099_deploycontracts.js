var Doug = artifacts.require("./Doug.sol");
var DataHelper = artifacts.require("./DataHelper.sol");
var DougEnabled = artifacts.require("./DougEnabled.sol");
var CoiDB = artifacts.require("./CoiDB.sol");
var Coi = artifacts.require("./Coi.sol");
var COIManager = artifacts.require("./COIManager.sol");
var Permission = artifacts.require("./Permission.sol");
var PermissionDB = artifacts.require("./PermissionDB.sol");
var DateTime = artifacts.require("./DateTime.sol");
var User = artifacts.require("./User.sol");
var UserDB = artifacts.require("./UserDB.sol");
var OwnerDB = artifacts.require("./OwnerDB.sol");
var Policy = artifacts.require("./Policy.sol");
var PolicyDB = artifacts.require("./PolicyDB.sol");



module.exports = function(deployer) {
  deployer.deploy(Doug);
  deployer.deploy(DataHelper);
  deployer.deploy(DougEnabled);
  deployer.deploy(DateTime);
  deployer.link(DateTime, CoiDB);
  deployer.link(DateTime, PolicyDB);
  deployer.deploy(CoiDB);
  deployer.deploy(Coi);
  deployer.deploy(COIManager);
  deployer.deploy(Permission);
  deployer.deploy(PermissionDB);
  deployer.deploy(User);
  deployer.deploy(UserDB);
  deployer.deploy(OwnerDB);
  deployer.deploy(Policy);
  deployer.deploy(PolicyDB);
};
