// 2_first_contracts.js
const ImagesStore = artifacts.require("ImagesStore");

module.exports = function(deployer) {
    deployer.deploy(ImagesStore);
};