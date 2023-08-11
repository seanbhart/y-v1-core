import { ethers as hhethers } from "hardhat";

import { Y, YFactory, YFactory__factory, Y__factory } from "../types";

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
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
