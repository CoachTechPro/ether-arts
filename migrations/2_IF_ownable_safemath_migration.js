var SafeMath = artifacts.require("./SafeMath.sol");
var Ownable = artifacts.require("./Ownable.sol");

module.exports = function(deployer) {
  deployer.then(async () =>{
    await deployer.deploy(SafeMath);
    await deployer.deploy(Ownable);
  })
};
