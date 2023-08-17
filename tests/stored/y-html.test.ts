import { expect } from "chai";
import ethers from "ethers";
import { ethers as hhethers } from "hardhat";

import { Y } from "../../types/contracts/stored";
import { Yo } from "../../types/contracts/stored";
import { Y__factory } from "../../types/factories/contracts/stored";
import { Yo__factory } from "../../types/factories/contracts/stored";

const devKey = process.env.ACCOUNT_KEY_PRIV_ACCT3;
const devKey2 = process.env.ACCOUNT_KEY_PRIV_ACCT2;

describe("Y Contract - HTML", function () {
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

  describe("HTML", function () {
    before(async () => {
      // Need to add the module to the contract
      await yContract.addModule(yoContract.target);
      // Need to create some content via the module
      const text1 = "hello there";
      const text2 = "general kenobi";
      let tx = await yContract.yeet(yoContract.target, await yoContract.serialize(text1));
      await tx.wait();
      tx = await yContract.yeet(yoContract.target, await yoContract.serialize(text2));
      await tx.wait();
    });

    it("Should have 2 yeets", async function () {
      const result = await yContract.getYeetstamps(yoContract.target);
      console.log("result", result);
      expect(result.length).to.equal(2);
    });

    it("Should retrieve the latest content from a module for a specific Y contract", async function () {
      // Call the wall function to get a specific user content from a single module
      const result = await yContract.wall(yoContract.target, 0);
      expect(result).to.equal(
        '<div class="yeet-feed"><div class="yeet"><div class="yeet-text">hello there</div></div><div class="yeet"><div class="yeet-text">general kenobi</div></div></div>',
      );
    });

    it("Should retrieve the latest content from all modules for a specific Y contract", async function () {
      // Call the walls function to get all content for a specific user
      const result = await yContract.walls(0);
      expect(result).to.equal(
        '<div class="yeet-feed"><div class="yeet"><div class="yeet-text">hello there</div></div><div class="yeet"><div class="yeet-text">general kenobi</div></div></div>',
      );
    });
  });
});
