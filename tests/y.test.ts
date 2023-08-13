import { assert, expect } from "chai";
import ethers from "ethers";
import { ethers as hhethers } from "hardhat";

import { Y, Y__factory, Yo, Yo__factory } from "../types";

const devKey = process.env.ACCOUNT_KEY_PRIV_ACCT3;
const devKey2 = process.env.ACCOUNT_KEY_PRIV_ACCT2;

describe("Y Contract", function () {
  const provider = hhethers.provider;
  let yContract: Y;
  let yContractOtherConnected: Y;
  let yoContract: Yo;
  let ownerAddr: string;
  let devAddr: string;
  let ownerSigner: ethers.Signer;
  let devSigner: ethers.Signer;

  before(async function () {
    // Create the owner wallet
    if (!devKey || !devKey2) {
      return;
    }
    const wallet = new hhethers.Wallet(devKey, provider);
    expect(wallet, "No wallet").to.exist;
    ownerAddr = wallet.address;
    ownerSigner = await provider.getSigner(ownerAddr);
    console.log("ownerAddr", ownerAddr);

    // Create another wallet
    const devWallet = new hhethers.Wallet(devKey2, provider);
    expect(devWallet, "No rdmDevWallet").to.exist;
    devAddr = devWallet.address;
    console.log("rdmAddr", devAddr);
    devSigner = await provider.getSigner(devAddr);

    yContract = await new Y__factory(ownerSigner).deploy(ownerAddr);
    console.log("Y contract target:", yContract.target);
    yContractOtherConnected = yContract.connect(devSigner);
    console.log("other Yo contract target:", yContractOtherConnected.target);

    yoContract = await new Yo__factory(ownerSigner).deploy();
    console.log("Yo contract target:", yoContract.target);

    // Send test ether to the contract to prep for the test
    const tx = await wallet.sendTransaction({
      to: yContract.target,
      value: hhethers.parseEther("1.0"),
    });
    await tx.wait();
    console.log("Sent 1.0 ETH to Yo contract");
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
    before(async () => {
      // remove all existing modules
      const modules = await yContract.getModules();
      console.log("found modules", modules);
      for (const module of modules) {
        await yContract.removeModule(module);
      }
    });

    it("Should allow owner to add a module", async function () {
      await yContract.addModule(yoContract.target);
      expect(await yContract.modules(0)).to.equal(yoContract.target);
    });

    it("Should allow owner to remove a module", async function () {
      await yContract.removeModule(yoContract.target);
      const modules = await yContract.getModules();
      expect(modules.length).to.equal(0);
    });

    it("Should emit event when module is added", async function () {
      await expect(yContract.addModule(yoContract.target))
        .to.emit(yContract, "ModuleAdded")
        .withArgs(yoContract.target);
    });

    it("Should NOT allow non-owner to add a module", async function () {
      await assert.isRejected(yContractOtherConnected.addModule(yoContract.target), /only owner/);
    });
  });

  describe("Ether", function () {
    // the contract should have 1 ether in it
    it("Should have 1 ether in the contract", async function () {
      expect(await provider.getBalance(yContract.target)).to.equal(hhethers.parseEther("1.0"));
    });

    // withdraw should send the ether to the owner
    it("Should withdraw ether to owner", async function () {
      const ownerBalanceBefore = await provider.getBalance(ownerAddr);
      await yContract.withdraw();
      const ownerBalanceAfter = await provider.getBalance(ownerAddr);
      expect(ownerBalanceAfter - ownerBalanceBefore).to.gt(hhethers.parseEther("0.99"));
    });
  });
});
