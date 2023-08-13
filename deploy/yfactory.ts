import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const yFactory = await deploy("YFactory", {
    from: deployer,
    log: true,
  });

  console.log(`YFactory contract: `, yFactory.address);
};

func.id = "deploy_yfactory";
func.tags = ["YFactory"];

export default func;
