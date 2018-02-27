var COIManager = artifacts.require("./COIManager.sol");
var Carrier = artifacts.require("./Carrier.sol");
var Doug = artifacts.require("./Doug.sol");
var CarrierDB = artifacts.require("./CarrierDB.sol");
var expect = require("chai").expect;


contract('COIManager', function(accounts) {
  let manager;
  let carrier;
  let carrierdb;

  beforeEach('setup manager', async function () {
    var doug = await Doug.deployed();
    manager = await COIManager.deployed();
    carrier = await Carrier.deployed();
    carrierdb = await CarrierDB.deployed();
    await doug.addContract("coiManager", manager.address);
    await doug.addContract("carrier", carrier.address);
    await doug.addContract("carrierDB", carrierdb.address);
    carrier = await doug.getContract.call("carrier");
    manager = await COIManager.deployed();
  });

  it("should create coi", async function() {
    await manager.createCoi(web3.fromAscii("123456"), carrier, web3.fromAscii("12/02/2018"), web3.fromAscii("12/02/2019"));
    let values = await manager.getCoi.call(web3.fromAscii("123456"));
    expect(values[0]).to.equal(carrier);
    expect(values[1].toNumber()).to.equal(0);
    expect(web3.toAscii(values[2])).to.include("12/02/2018");
    expect(web3.toAscii(values[3])).to.include("12/02/2019");
  });

  it("should cancel coi", async function() {
    await manager.createCoi(web3.fromAscii("123456"), carrier, web3.fromAscii("12/02/2018"), web3.fromAscii("12/02/2019"));
    await manager.cancelCOI(web3.fromAscii("123456"));
    let isCanceled = await manager.isCOIActive(web3.fromAscii("123456"));
    expect(isCanceled).to.equal(false);
  })

});
