import { assert, expect } from "chai";
import ethers from "ethers";
import { ethers as hhethers } from "hardhat";

import { Y } from "../../types/contracts/stored";
import { Mock } from "../../types/contracts/utils";
import { Y__factory } from "../../types/factories/contracts/stored";
import { Mock__factory } from "../../types/factories/contracts/utils";

const devKey = process.env.ACCOUNT_KEY_PRIV_DEV01;
const devKey2 = process.env.ACCOUNT_KEY_PRIV_DEV04;

describe("Y Contract - Info", function () {
  const provider = hhethers.provider;
  let yContract: Y;
  let erc721Mock: Mock;
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

    erc721Mock = await new Mock__factory(ownerSigner).deploy();
  });

  describe("username", function () {
    it("returns the correct username", async function () {
      const username = "testUsername";
      await yContract.setUsername(username);
      expect(await yContract.username()).to.equal(username);
    });

    it("reverts when a non-owner tries to set the username", async function () {
      const username = "testUsername";
      await assert.isRejected(yContract.connect(devSigner).setUsername(username), /only owner/);
    });
  });

  describe("bio", function () {
    it("returns the correct bio", async function () {
      const bio = "testBio";
      await yContract.setBio(bio);
      expect(await yContract.bio()).to.equal(bio);
    });

    it("reverts when a non-owner tries to set the bio", async function () {
      const bio = "testBio";
      await assert.isRejected(yContract.connect(devSigner).setBio(bio), /only owner/);
    });
  });

  describe("setAvatar", function () {
    it("sets the avatar to the tokenURI of the owned NFT", async function () {
      const tokenId = 1;
      await erc721Mock.mint(ownerAddr, tokenId);
      const tokenURI = await erc721Mock.tokenURI(tokenId);
      await yContract.setAvatar(erc721Mock.target, tokenId);
      expect(await yContract.avatar()).to.equal(tokenURI);
    });

    it("reverts when the caller does not own the NFT", async function () {
      const tokenId = 2;
      await erc721Mock.mint(devAddr, tokenId);
      await assert.isRejected(yContract.setAvatar(erc721Mock.target, tokenId), "Caller does not own the NFT");
    });
  });
});
