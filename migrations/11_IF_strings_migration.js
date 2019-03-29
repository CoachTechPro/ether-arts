var strings = artifacts.require("./strings.sol");

module.exports = function(deployer) {
  deployer.then(async () =>{
    var IF_strings = await deployer.deploy(strings);
  })
};

