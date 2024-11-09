require("@nomicfoundation/hardhat-toolbox");
require("@chainlink/env-enc").config();
require("./tasks");

const SEPOLIA_URL = process.env.SEPOLIA_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY
const PRIVATE_KEY_1 = process.env.PRIVATE_KEY_1
const API_KEY     = process.env.API_KEY

const { ProxyAgent, setGlobalDispatcher } = require("undici");
const proxyAgent = new ProxyAgent("http://127.0.0.1:7890");
setGlobalDispatcher(proxyAgent);

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  networks: {
    sepolia: {
      url: SEPOLIA_URL,
      accounts: [PRIVATE_KEY, PRIVATE_KEY_1],
      chainId: 11155111
    }
  },
  etherscan: {
    apiKey: {
      sepolia: API_KEY
    },
    // resolve verify in sepolia timeout
    customChains: [
      {
        network: "rinkeby",
        chainId: 4,
        urls: {
          apiURL: "http://api-rinkeby.etherscan.io/api",  // https => http
          browserURL: "https://rinkeby.etherscan.io"
        }
      }
    ]
  },
  sourcify: {
    // Disabled by default
    // Doesn't need an API key
    enabled: true
  }
};
