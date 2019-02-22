pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/KYC.sol";
import "../contracts/ThrowProxy.sol";

contract TestKYCUserInfo {

    function testCreateUserInfo() public {
        KYC contractKYC = new KYC();

        ThrowProxy throwProxy = new ThrowProxy(address(contractKYC));

        address addr = 0x1111111111111111111111111111111111111111;
        string memory hash = "2222222222222222222222222222222222222222222222222222222222222222";
        uint valueNodes = 13;

        KYC(address(throwProxy)).createUserInfo(addr, hash, valueNodes);

        bool result = throwProxy.execute.gas(200000)();
        Assert.equal(result, false, "There was no throw");

        contractKYC.changeServerAddr(this);
        contractKYC.createUserInfo(addr, hash, valueNodes);

        (string memory hashInfo, uint nodesInfo, bool validInfo) = contractKYC.informations(addr);

        Assert.equal(keccak256(hashInfo), keccak256(hash), "Invalid hashData");
        Assert.equal(nodesInfo, valueNodes, "Invalid valueNodes");
        Assert.equal(validInfo, false, "Invalid valid");
    }

    function testCreateManyUserInfo() public {
        KYC contractKYC = new KYC();

        uint countUserInfo = 10;
        address[] memory addresses;
        string[] memory hashes;
        uint[] memory nodes;

        addresses = new address[](countUserInfo);
        hashes = new string[](countUserInfo);
        nodes = new uint[](countUserInfo);

        contractKYC.changeServerAddr(this);

        for(uint i = 1; i < countUserInfo + 1; i++) {
            addresses[i - 1] = address(i);
            hashes[i - 1] = "123";
            nodes[i - 1] = i;
            contractKYC.createUserInfo(address(i), hashes[i - 1], i);
        }

        for(uint j = 0; j < countUserInfo; j++) {
            (string memory hashInfo, uint nodesInfo, bool validInfo) = contractKYC.informations(addresses[j]);
            Assert.equal(hashInfo, hashes[j], "Invalid hashData");
            Assert.equal(nodesInfo, nodes[j], "Invalid valueNodes");
            Assert.equal(validInfo, false, "Invalid valid");
        }
    }

    function testChangeUserInfo() public {
        KYC contractKYC = new KYC();

        ThrowProxy throwProxy = new ThrowProxy(address(contractKYC));

        address addr = 0x1111111111111111111111111111111111111111;
        string memory hash1 = "1111111111111111111111111111111111111111111111111111111111111111";
        string memory hash2 = "2222222222222222222222222222222222222222222222222222222222222222";
        uint valueNodes1 = 13;
        uint valueNodes2 = 31;

        contractKYC.changeServerAddr(this);
        contractKYC.createUserInfo(addr, hash1, valueNodes1);

        (string memory hashInfo, uint nodesInfo, bool validInfo) = contractKYC.informations(addr);
        Assert.equal(hashInfo, hash1, "Invalid hashData");
        Assert.equal(nodesInfo, valueNodes1, "Invalid valueNodes");
        Assert.equal(validInfo, false, "Invalid valid");

        contractKYC.changeServerAddr(address(0));

        KYC(address(throwProxy)).changeUserInfo(addr, hash2, valueNodes2);

        bool result = throwProxy.execute.gas(200000)();
        Assert.equal(result, false, "There was no throw");

        contractKYC.changeServerAddr(this);
        contractKYC.changeUserInfo(addr, hash2, valueNodes2);

        (string memory hashInfo2, uint nodesInfo2, bool validInfo2) = contractKYC.informations(addr);
        Assert.equal(hashInfo2, hash2, "Invalid hashData");
        Assert.equal(nodesInfo2, valueNodes2, "Invalid valueNodes");
        Assert.equal(validInfo2, false, "Invalid valid");
    }

    function testChangeManyUserInfo() public {
        KYC contractKYC = new KYC();

        uint countUserInfo = 10;
        address[] memory addresses;
        string[] memory hashes;
        uint[] memory nodes;

        addresses = new address[](countUserInfo);
        hashes = new string[](countUserInfo);
        nodes = new uint[](countUserInfo);

        contractKYC.changeServerAddr(this);

        for(uint i = 1; i < countUserInfo + 1; i++) {
            addresses[i - 1] = address(i);
            hashes[i - 1] = "123";
            nodes[i - 1] = i;
            contractKYC.createUserInfo(address(i), hashes[i - 1], i);
        }

        for(uint j = 0; j < countUserInfo; j++) {
            (string memory hashInfo1, uint nodesInfo1, bool validInfo1) = contractKYC.informations(addresses[j]);
            Assert.equal(hashInfo1, hashes[j], "Invalid hashData");
            Assert.equal(nodesInfo1, nodes[j], "Invalid valueNodes");
            Assert.equal(validInfo1, false, "Invalid valid");
        }

        for(uint k = 1; k < countUserInfo + 1; k++) {
            hashes[k - 1] = "321";
            nodes[k - 1] = k + 1;
            contractKYC.changeUserInfo(addresses[k - 1], hashes[k - 1], nodes[k - 1]);
        }

        for(uint l = 0; l < countUserInfo; l++) {
            (string memory hashInfo2, uint nodesInfo2, bool validInfo2) = contractKYC.informations(addresses[l]);
            Assert.equal(hashInfo2, hashes[l], "Invalid hashData");
            Assert.equal(nodesInfo2, nodes[l], "Invalid valueNodes");
            Assert.equal(validInfo2, false, "Invalid valid");
        }
    }
}