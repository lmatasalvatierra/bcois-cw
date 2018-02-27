var Doug = artifacts.require("./Doug.sol");
var DougEnabled = artifacts.require("./DougEnabled.sol");
var expect = require("chai").expect;


contract('Doug', function(accounts) {
  let doug_enabled;
  let doug;

  beforeEach('setup test doug and doug_enabled object', async function () {
    doug = await Doug.deployed();
    doug_enabled = await DougEnabled.deployed();
    console.log(doug);
    console.log("******************");
    console.log(doug_enabled);
    console.log("******************");
  });

  it("should add dougEnabled contract", async function() {
    await doug.addContract("test", doug_enabled.address);
    expect(dougEnabled.address).to.equal(await doug.getContract.call("test"));
  });
});
