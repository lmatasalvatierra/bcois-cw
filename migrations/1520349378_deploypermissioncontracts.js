var Permission = artifacts.require("./Permission.sol");
var PermissionDB = artifacts.require("./PermissionDB.sol");

module.exports = function(deployer) {
  deployer.deploy(Permission);
  deployer.deploy(PermissionDB);
};
