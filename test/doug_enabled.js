var DougEnabled = artifacts.require("./DougEnabled.sol");
var expect = require("chai").expect;


contract('DougEnabled', function(accounts) {
  let doug_enabled;
  let testing_account = accounts[0];
  let hacker_account = accounts[1];

  beforeEach('setup doug_enabled object', async function () {
    doug_enabled = await DougEnabled.new();
  });

  describe("setDougAddress", function() {
    it("should set DOUG address in contract", async function() {
      await doug_enabled.setDougAddress(testing_account, {from: testing_account});
      let received_address = await doug_enabled.getDougAddress();
      expect(received_address).to.equal(testing_account);
    });

    it("should not set address bc it has already been set by another account", async function() {
      await doug_enabled.setDougAddress(testing_account, {from: testing_account});
      let result = await doug_enabled.setDougAddress(hacker_account, {from: hacker_account});
      expect(await doug_enabled.getDougAddress()).to.equal(testing_account);
    });
  });
});
