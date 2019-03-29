
var path = require('path');
module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  contracts_build_directory: path.join(__dirname, "./src/build/contracts"),

  networks: {
    development: {
      host: "121.125.73.15",
      port: 7545,
      network_id: "*", // Match any network id
      gas: 6500000, // Block Gas Limit same as latest on Mainnet https://ethstats.net/    Ganache : 7500000
      gasPrice: 5000000000 // same as latest on Mainnet https://ethstats.net/             Ganache : 7.1 gwei
    },

    rinkeby: { // my rinkeby node on MalimServer2

      network_id: 4,
      gas: 6500000,
      gasPrice: 8000000000,
    },

    rinkeby_infura: {
      network_id: 4,
      gas: 6500000,
      gasPrice: 8000000000,
    },

    kovan: {
      network_id: 42,
      gas: 6500000,
      gasPrice: 7000000000,
    },

    ropsten: {
      network_id: 3,
      gas: 6500000,
      gasPrice: 7000000000,
    },

    default_success: {
      host: "121.125.73.15",
      port: 7545,
      network_id: "*", // Match any network id
      gas: 8000000, // Block Gas Limit same as latest on Mainnet https://ethstats.net/
      gasPrice: 21000 // same as latest on Mainnet https://ethstats.net/
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 20
    }
  },
  mocha: {
    enableTimeouts: false
  }
};
