import { ethers as hhethers } from "hardhat";

// import ERC20ABI from "../assets/ERC20ABI.json";
import { Y, Y__factory } from "../types";
import { YFactory, YFactory__factory } from "../types";

const Y_FACTORY_ADDRESS = process.env.Y_FACTORY_ADDRESS_OPTIMISM;
const devKey = process.env.ACCOUNT_KEY_PRIV_DEV01;

async function main() {
  if (!Y_FACTORY_ADDRESS || !devKey) {
    return;
  }
  console.log("Y_FACTORY_ADDRESS", Y_FACTORY_ADDRESS);
  const YFactoryFactory = (await hhethers.getContractFactory("YFactory")) as YFactory__factory;
  const yFactory = YFactoryFactory.attach(Y_FACTORY_ADDRESS) as YFactory;

  // Create a new Y contract
  const tx = await yFactory.create();
  await tx.wait();

  // check for stored created contracts
  const yContracts = await yFactory.getMy();
  console.log("yContracts", yContracts);

  // check the logs
  const filter = yFactory.filters.Created();
  const logs = await yFactory.queryFilter(filter);
  console.log("logs", logs);
  const newYAddress = logs[0].args?.y;
  console.log("newYAddress", newYAddress);

  const YFactory = (await hhethers.getContractFactory("Y")) as Y__factory;
  const newYContract = YFactory.attach(newYAddress) as Y;
  console.log("newYContract", newYContract);

  // // Test with an ERC20 contract
  // const address = "0xbC75bBb748CEEC2E36D07BE92A0663d75ef6635d";
  // const erc20ContractAddress = "0x7F5c764cBc14f9669B88837ca1490cCa17c31607"; // Optimism USDC
  // const erc20Contract = await hhethers.getContractAt(ERC20ABI, erc20ContractAddress);
  // const balance = await erc20Contract.balanceOf(address);
  // console.log(`Balance of address ${address}: ${balance}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
