import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "@okxweb3/hardhat-explorer-verify"; // Import the plugin

const ACCOUNT_PRIVATE_KEY = vars.get("ACCOUNT_PRIVATE_KEY");
const MAINNET_ACCOUNT_PRIVATE_KEY = vars.get("MAINNET_ACCOUNT_PRIVATE_KEY");

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.24",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
          evmVersion: "london",
        },
      },
    ],
  },
  networks: {
    skaleNebulaTestnet: {
      url: "https://testnet.skalenodes.com/v1/lanky-ill-funny-testnet",
      accounts: [`0x${ACCOUNT_PRIVATE_KEY}`],
    },
    skaleNebulaMainnet: {
      url: "https://mainnet.skalenodes.com/v1/green-giddy-denebola",
      accounts: [`0x${MAINNET_ACCOUNT_PRIVATE_KEY}`],
    },
  },
};

export default config;
