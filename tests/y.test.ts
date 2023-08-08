import { assert, expect } from "chai";
import ethers from "ethers";
import { ethers as hhethers } from "hardhat";

import { Y, Y__factory, Yo, Yo__factory } from "../types";

const devKey = process.env.ACCOUNT_KEY_PRIV_ACCT3;
const devKey2 = process.env.ACCOUNT_KEY_PRIV_ACCT2;

describe("Yo Contract", function () {
  let yContract: Y;
  let yContractOtherConnected: Y;
  let yoContract: Yo;
  let ownerAddr: string;
  let devAddr: string;
  let ownerSigner: ethers.Signer;
  let devSigner: ethers.Signer;

  before(async function () {
    const provider = new hhethers.JsonRpcProvider();
    expect(devKey, "No dev key").to.exist;

    if (!devKey || !devKey2) {
      return;
    }
    // Create the owner wallet
    const wallet = new hhethers.Wallet(devKey, provider);
    expect(wallet, "No wallet").to.exist;
    ownerAddr = wallet.address;
    ownerSigner = await hhethers.provider.getSigner(ownerAddr);
    console.log("ownerAddr", ownerAddr);

    // Create another wallet
    const devWallet = new hhethers.Wallet(devKey2, provider);
    expect(devWallet, "No rdmDevWallet").to.exist;
    devAddr = devWallet.address;
    console.log("rdmAddr", devAddr);
    devSigner = await hhethers.provider.getSigner(devAddr);

    yContract = await new Y__factory(ownerSigner).deploy(ownerAddr);
    console.log("Y contract target:", yContract.target);
    yContractOtherConnected = yContract.connect(devSigner);
    console.log("other Yo contract target:", yContractOtherConnected.target);

    yoContract = await new Yo__factory(ownerSigner).deploy();
    console.log("Yo contract target:", yoContract.target);
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await yContract.isOwner(ownerAddr)).to.equal(true);
    });

    it("Should not set non-owners as owner", async function () {
      expect(await yContract.isOwner(devAddr)).to.equal(false);
    });
  });

  describe("Modules", function () {
    it("Should allow owner to add a module", async function () {
      await yContract.addModule(yoContract.target);
      expect(await yContract.modules(0)).to.equal(yoContract.target);
    });

    it("Should emit event when module is added", async function () {
      await expect(yContract.addModule(yoContract.target))
        .to.emit(yContract, "ModuleAdded")
        .withArgs(yoContract.target);
    });

    it("Should NOT allow non-owner to add a module", async function () {
      await assert.isRejected(yContractOtherConnected.addModule(yoContract.target), /only owner/);
    });

    it("Should setMe based on caller address", async function () {
      const timestamp = Math.floor(Date.now() / 1000);
      const structName = hhethers.encodeBytes32String("Yeet");
      const text = hhethers.encodeBytes32String("hello there");
      const yeetData = hhethers.AbiCoder.defaultAbiCoder().encode(["uint256", "string"], [timestamp, text]);
      await yContract.setMe(structName, timestamp, yeetData);
      // expect the data to now be in the me hash table
      expect(await yContract.me(ownerAddr, structName, timestamp)).to.equal(yeetData);
    });
  });
});
