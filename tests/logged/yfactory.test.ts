// tests/YFactory.test.ts
import { expect } from "chai";
import ethers from "ethers";
import { ethers as hhethers } from "hardhat";

import YArtifact from "../../artifacts/contracts/logged/Y.sol/Y.json";
import { Y } from "../../types/contracts/logged";
import { YFactory } from "../../types/contracts/logged";
import { Y__factory } from "../../types/factories/contracts/logged";
import { YFactory__factory } from "../../types/factories/contracts/logged";

const devKey = process.env.ACCOUNT_KEY_PRIV_DEV01;

describe("YFactory Contract", function () {
  const provider = hhethers.provider;
  let yFactory: YFactory;
  let ownerAddr: string;
  let ownerSigner: ethers.Signer;

  before(async function () {
    // Create the owner wallet
    if (!devKey) {
      return;
    }
    const wallet = new hhethers.Wallet(devKey, provider);
    expect(wallet, "No wallet").to.exist;
    ownerAddr = wallet.address;
    ownerSigner = await provider.getSigner(ownerAddr);
    console.log("ownerAddr", ownerAddr);

    yFactory = await new YFactory__factory(ownerSigner).deploy();
    console.log("yFactory contract target:", yFactory.target);
  });

  it("Should create a new Y contract", async function () {
    const tx = await yFactory.create();
    const receipt = await tx.wait();
    if (!receipt) {
      throw new Error("No receipt");
    }

    // check for stored created contracts
    const yContracts = await yFactory.getMy();
    console.log("yContracts", yContracts);

    // check the logs
    const filter = yFactory.filters.Created();
    const logs = await yFactory.queryFilter(filter);
    console.log("logs", logs);
    expect(logs.length).to.equal(1);
    const newYAddress = logs[0].args?.y;
    console.log("newYAddress", newYAddress);
    expect(newYAddress).to.exist;

    const YFactory = new hhethers.ContractFactory(YArtifact.abi, YArtifact.bytecode) as Y__factory;
    const newYContract = YFactory.attach(newYAddress) as Y;
    expect(newYContract).to.exist;
  });
});
