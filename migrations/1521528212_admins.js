var Admins = artifacts.require("./Admins.sol");

module.exports = function(deployer) {
  deployer.deploy(Admins);
};
