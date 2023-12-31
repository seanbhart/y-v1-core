import "@nomicfoundation/hardhat-toolbox";
import { config as dotenvConfig } from "dotenv";
import "hardhat-deploy";
import "hardhat-gas-reporter";
import type { HardhatUserConfig } from "hardhat/config";
import { resolve } from "path";

dotenvConfig({ path: resolve(__dirname, ".env") });
const devMode = process.env.DEV_MODE || true;

let key = process.env.ACCOUNT_KEY_PRIV_DEV01 || "";
const devKey = process.env.ACCOUNT_KEY_PRIV_DEV01 || "";
const devKey1 = process.env.ACCOUNT_KEY_PRIV_DEV01 || "";
const devKey2 = process.env.ACCOUNT_KEY_PRIV_DEV01 || "";
const devKey4 = process.env.ACCOUNT_KEY_PRIV_DEV04 || "";
if (devMode) {
  console.log("devMode: ", devMode);
  key = devKey;
}

const chainIds = {
  "arbitrum-mainnet": 42161,
  avalanche: 43114,
  bsc: 56,
  ganache: 1337,
  hardhat: 31337,
  mainnet: 1,
  "optimism-mainnet": 10,
  "polygon-mainnet": 137,
  "polygon-mumbai": 80001,
  sepolia: 11155111,
};

const config: HardhatUserConfig = {
  defaultNetwork: "hardhat",
  namedAccounts: {
    deployer: 0,
  },
  etherscan: {
    apiKey: {
      arbitrumOne: process.env.ARBISCAN_API_KEY || "",
      avalanche: process.env.SNOWTRACE_API_KEY || "",
      bsc: process.env.BSCSCAN_API_KEY || "",
      mainnet: process.env.ETHERSCAN_API_KEY || "",
      optimisticEthereum: process.env.OPTIMISM_API_KEY || "",
      polygon: process.env.POLYGONSCAN_API_KEY || "",
      polygonMumbai: process.env.POLYGONSCAN_API_KEY || "",
      sepolia: process.env.ETHERSCAN_API_KEY || "",
    },
  },
  gasReporter: {
    token: "ETH",
    currency: "USD",
    gasPrice: 1, // 1 Gwei is the lowest possible setting - L2s are lower in reality
    coinmarketcap: `${process.env.COIN_MARKET_CAP}`,
    enabled: process.env.REPORT_GAS ? true : false,
    excludeContracts: [],
    src: "./contracts",
  },
  networks: {
    hardhat: {
      accounts: [
        {
          privateKey: devKey,
          balance: "10000000000000000000",
        },
        {
          privateKey: devKey1,
          balance: "10000000000000000000",
        },
        {
          privateKey: devKey2,
          balance: "10000000000000000000",
        },
        {
          privateKey: devKey4,
          balance: "10000000000000000000",
        },
      ],
      chainId: chainIds.hardhat,
    },
    local: {
      url: `${process.env.NETWORK_LOCAL}`,
      // chainId: 31337,
      accounts: [`0x${process.env.ACCOUNT_KEY_PRIV_LOCAL}`],
      forking: {
        url: `${process.env.NETWORK_FORK}`,
      },
    },
    polygon: {
      url: `${process.env.NETWORK_POLYGON}`,
      accounts: [`0x${process.env.ACCOUNT_KEY_PRIV_DEV04}`],
      gasPrice: 150000000000, // 150 Gwei
    },
    optimism: {
      url: `${process.env.NETWORK_OPTIMISM}`,
      accounts: [`0x${process.env.ACCOUNT_KEY_PRIV_DEV04}`],
      // gasPrice: 1000000000, // 1 Gwei
    },
    "optimism-goerli": {
      url: `${process.env.NETWORK_OPTIMISM_GOERLI}`,
      accounts: [`0x${process.env.ACCOUNT_KEY_PRIV_DEV04}`],
      gasPrice: 1000000000, // 1 Gwei
    },
    "zk-evm": {
      url: "https://zkevm-rpc.com",
      accounts: [key as string],
      gasPrice: 2000000000, // 2 Gwei
    },
    zksync: {
      url: "https://mainnet.era.zksync.io",
      accounts: [key as string],
      gasPrice: 1000000000, // 1 Gwei
    },
    "zora-goerli": {
      url: "https://testnet.rpc.zora.energy/",
      accounts: [key as string],
    },
    "zora-mainnet": {
      url: "https://rpc.zora.energy/",
      chainId: 7777777,
      accounts: [key as string],
      gasPrice: 2000000000, // 2 Gwei
    },
  },
  paths: {
    artifacts: "./artifacts",
    cache: "./cache",
    sources: "./contracts",
    tests: "./test",
  },
  solidity: {
    version: "0.8.17",
    settings: {
      metadata: {
        // Not including the metadata hash
        // https://github.com/paulrberg/hardhat-template/issues/31
        bytecodeHash: "none",
      },
      // Disable the optimizer when debugging
      // https://hardhat.org/hardhat-network/#solidity-optimizer-support
      optimizer: {
        enabled: true,
        runs: 800,
      },
      viaIR: true,
    },
  },
  typechain: {
    outDir: "types",
    target: "ethers-v6",
    // alwaysGenerateOverloads: false, // should overloads with full signatures like deposit(uint256) be generated always, even if there are no overloads?
    // externalArtifacts: ["node_modules/@openzeppelin/**/*.json"], // allows you to manually specify the external artifacts that should be processed by the TypeChain (glob pattern)
  },
};

export default config;
