import { expect } from "chai";
import ethers from "ethers";
import { ethers as hhethers } from "hardhat";

import { Y } from "../../types/contracts/stored";
import { Yo } from "../../types/contracts/stored";
import { Y__factory } from "../../types/factories/contracts/stored";
import { Yo__factory } from "../../types/factories/contracts/stored";

const devKey = process.env.ACCOUNT_KEY_PRIV_ACCT3;
const devKey2 = process.env.ACCOUNT_KEY_PRIV_ACCT2;

describe("Y Contract - JSON", function () {
  const provider = hhethers.provider;
  let yContract: Y;
  let yContractOtherConnected: Y;
  let yoContract: Yo;
  let ownerAddr: string;
  let devAddr: string;
  let ownerSigner: ethers.Signer;
  let devSigner: ethers.Signer;
  let earliest: number;

  before(async function () {
    earliest = 0;
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
  });

  it("should return the correct JSON string", async function () {
    const result = await yContract.recentJson(yoContract.target, earliest);
    console.log("result", result);
    expect(result).to.not.be.undefined;
  });
});
