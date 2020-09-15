const DAO = artifacts.require("DAO");

module.exports = function (deployer, _network, accounts) {
    deployer.deploy(DAO, 60,60,50);
};
