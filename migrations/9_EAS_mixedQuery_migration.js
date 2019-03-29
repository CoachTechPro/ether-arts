var EAS_mixedQuery = artifacts.require("./EAS_mixedQuery.sol");

var EAS_types = artifacts.require("./EAS_types.sol");
var EAS_artworks = artifacts.require("./EAS_artworks.sol");
var EAS_platform = artifacts.require("./EAS_platform.sol");

var SafeMath = artifacts.require("./SafeMath.sol");
var Ownable = artifacts.require("./Ownable.sol");

module.exports = function(deployer) {
  deployer.then(async () =>{
    var IF_EAS_artworks = await EAS_artworks.deployed();
    var IF_EAS_types = await EAS_types.deployed();
    var IF_EAS_platform = await EAS_platform.deployed();

    var IF_SafeMath = await SafeMath.deployed();
    var IF_Ownable = await Ownable.deployed();

    await deployer.link(SafeMath, EAS_mixedQuery);
    await deployer.link(Ownable, EAS_mixedQuery);

    await deployer.deploy(EAS_mixedQuery, EAS_types.address, EAS_artworks.address, EAS_platform.address);
    IF_EAS_platform.allowAccess(EAS_mixedQuery.address);
  })
};
