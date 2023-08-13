import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  const y = await deploy("Y", {
    from: deployer,
    args: [deployer], // assuming the owner is the deployer
    log: true,
  });

  console.log(`Y contract: `, y.address);
};

func.id = "deploy_y";
func.tags = ["Y"];

export default func;
