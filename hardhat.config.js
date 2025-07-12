require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    fhenix: {
      url: process.env.FHENIX_TESTNET_URL || "https://testnet.fhenix.io",
      accounts: [process.env.PRIVATE_KEY],
    },
  },
};
