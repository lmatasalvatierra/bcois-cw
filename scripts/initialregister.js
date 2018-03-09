var Permission = artifacts.require("./Permission.sol");
var PermissionDB = artifacts.require("./PermissionDB.sol");
var COIManager = artifacts.require("./COIManager.sol");
var Carrier = artifacts.require("./Carrier.sol");
var Doug = artifacts.require("./Doug.sol");
var CarrierDB = artifacts.require("./CarrierDB.sol");

module.exports = async function(callback) {
  let manager = await COIManager.deployed();
  await manager.setPermission('0xf17f52151EbEF6C7334FAD080c5704D77216b732', web3.fromDecimal('2'));
  await manager.createCoi(web3.fromAscii("123456"), '0xf17f52151EbEF6C7334FAD080c5704D77216b732', '0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef', web3.fromAscii("12/02/2018"), web3.fromAscii("12/02/2019"), {from: '0xf17f52151EbEF6C7334FAD080c5704D77216b732'});
  let values = await manager.getCoi.call(web3.fromAscii("123456"));
  console.log(values);
};
