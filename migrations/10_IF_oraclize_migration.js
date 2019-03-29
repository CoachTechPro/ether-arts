
var usingOraclize = artifacts.require("./usingOraclize.sol");

module.exports = function(deployer) {
  deployer.then(async () =>{
    var IF_usingOraclize = await deployer.deploy(usingOraclize);
  })
};

