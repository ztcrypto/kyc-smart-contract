pragma solidity ^0.4.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/KYC.sol";
import "../contracts/ThrowProxy.sol";

contract TestKYC {
	
	uint public initialBalance = 1000 wei;

	function testCreateKYC() public {
		KYC contractKYC = new KYC();

		bool isAdmin = contractKYC.admins(this);
		Assert.equal(isAdmin, true, "Wrong admin address");

		address serverAddress = contractKYC.serverAddress();
		Assert.equal(serverAddress, 0x0000000000000000000000000000000000000000, "Wrong server address");
	}

	function testCreateUserInfo() public {
		KYC contractKYC = new KYC();

		ThrowProxy throwProxy = new ThrowProxy(address(contractKYC));

		address addr = 0x1111111111111111111111111111111111111111;
		bytes32 hash = 2222222222222222222222222222222222222222222222222222222222222222;
		uint valueNodes = 13;

		KYC(address(throwProxy)).createUserInfo(addr, hash, valueNodes);

		bool result = throwProxy.execute.gas(200000)();
		Assert.equal(result, false, "There was no throw");

		contractKYC.changeServerAddr(this);
		contractKYC.createUserInfo(addr, hash, valueNodes);

		var(hashInfo, nodesInfo, validInfo) = contractKYC.informations(addr);
		Assert.equal(hashInfo, hash, "Invalid hashData");
		Assert.equal(nodesInfo, valueNodes, "Invalid valueNodes");
		Assert.equal(validInfo, false, "Invalid valid");
	}

	function testCreateManyUserInfo() public {
		KYC contractKYC = new KYC();

		uint countUserInfo = 10;
		address[] memory addresses;
		bytes32[] memory hashes;
		uint[] memory nodes;

		addresses = new address[](countUserInfo);
		hashes = new bytes32[](countUserInfo);
		nodes = new uint[](countUserInfo);

		contractKYC.changeServerAddr(this);

		for(uint i = 1; i < countUserInfo + 1; i++) {
			addresses[i - 1] = address(i);
			hashes[i - 1] = bytes32(i);
			nodes[i - 1] = i;
			contractKYC.createUserInfo(address(i), bytes32(i), i);
		}

		for(uint j = 0; j < countUserInfo; j++) {
			var(hashInfo, nodesInfo, validInfo) = contractKYC.informations(addresses[j]);
			Assert.equal(hashInfo, hashes[j], "Invalid hashData");
			Assert.equal(nodesInfo, nodes[j], "Invalid valueNodes");
			Assert.equal(validInfo, false, "Invalid valid");
		}
	}

	function testChangeUserInfo() public {
		KYC contractKYC = new KYC();

		ThrowProxy throwProxy = new ThrowProxy(address(contractKYC));

		address addr = 0x1111111111111111111111111111111111111111;
		bytes32 hash1 = 1111111111111111111111111111111111111111111111111111111111111111;
		bytes32 hash2 = 2222222222222222222222222222222222222222222222222222222222222222;
		uint valueNodes1 = 13;
		uint valueNodes2 = 31;

		contractKYC.changeServerAddr(this);
		contractKYC.createUserInfo(addr, hash1, valueNodes1);

		var(hashInfo, nodesInfo, validInfo) = contractKYC.informations(addr);
		Assert.equal(hashInfo, hash1, "Invalid hashData");
		Assert.equal(nodesInfo, valueNodes1, "Invalid valueNodes");
		Assert.equal(validInfo, false, "Invalid valid");

		contractKYC.changeServerAddr(address(0));

		KYC(address(throwProxy)).changeUserInfo(addr, hash2, valueNodes2);

		bool result = throwProxy.execute.gas(200000)();
		Assert.equal(result, false, "There was no throw");

		contractKYC.changeServerAddr(this);
		contractKYC.changeUserInfo(addr, hash2, valueNodes2);

		var(hashInfo2, nodesInfo2, validInfo2) = contractKYC.informations(addr);
		Assert.equal(hashInfo2, hash2, "Invalid hashData");
		Assert.equal(nodesInfo2, valueNodes2, "Invalid valueNodes");
		Assert.equal(validInfo2, false, "Invalid valid");
	}

	function testChangeManyUserInfo() public {
		KYC contractKYC = new KYC();

		uint countUserInfo = 10;
		address[] memory addresses;
		bytes32[] memory hashes;
		uint[] memory nodes;

		addresses = new address[](countUserInfo);
		hashes = new bytes32[](countUserInfo);
		nodes = new uint[](countUserInfo);

		contractKYC.changeServerAddr(this);

		for(uint i = 1; i < countUserInfo + 1; i++) {
			addresses[i - 1] = address(i);
			hashes[i - 1] = bytes32(i);
			nodes[i - 1] = i;
			contractKYC.createUserInfo(address(i), bytes32(i), i);
		}

		for(uint j = 0; j < countUserInfo; j++) {
			var(hashInfo1, nodesInfo1, validInfo1) = contractKYC.informations(addresses[j]);
			Assert.equal(hashInfo1, hashes[j], "Invalid hashData");
			Assert.equal(nodesInfo1, nodes[j], "Invalid valueNodes");
			Assert.equal(validInfo1, false, "Invalid valid");
		}

		for(uint k = 1; k < countUserInfo + 1; k++) {
			hashes[k - 1] = bytes32(k + 1);
			nodes[k - 1] = k + 1;
			contractKYC.changeUserInfo(addresses[k - 1], hashes[k - 1], nodes[k - 1]);
		}

		for(uint l = 0; l < countUserInfo; l++) {
			var(hashInfo2, nodesInfo2, validInfo2) = contractKYC.informations(addresses[l]);
			Assert.equal(hashInfo2, hashes[l], "Invalid hashData");
			Assert.equal(nodesInfo2, nodes[l], "Invalid valueNodes");
			Assert.equal(validInfo2, false, "Invalid valid");
		}
	}

	function testUserAuthorization() public {
		KYC contractKYC = new KYC();

		ThrowProxy throwProxy = new ThrowProxy(address(contractKYC));

		address addr = this;
		bytes32 hash = 1111111111111111111111111111111111111111111111111111111111111111;
		uint valueNodes = 13;

		contractKYC.changeServerAddr(this);
		contractKYC.createUserInfo(addr, hash, valueNodes);

		var(hashInfo, nodesInfo, validInfo) = contractKYC.informations(addr);
		Assert.equal(hashInfo, hash, "Invalid hashData");
		Assert.equal(nodesInfo, valueNodes, "Invalid valueNodes");
		Assert.equal(validInfo, false, "Invalid valid");

		KYC(address(throwProxy)).userAuthorization();

		bool result1 = throwProxy.execute.gas(200000)();
		Assert.equal(result1, false, "There was no throw");

		contractKYC.userAuthorization.value(1)();
		var(hashInfo2, nodesInfo2, validInfo2) = contractKYC.informations(addr);
		Assert.equal(hashInfo2, hash, "Invalid hashData");
		Assert.equal(nodesInfo2, valueNodes, "Invalid valueNodes");
		Assert.equal(validInfo2, true, "Invalid valid");

		uint balanceKYC = address(contractKYC).balance;
		Assert.equal(this.balance, initialBalance - 1, "Invalid balance");
		Assert.equal(balanceKYC, 1, "Invalid balance");
	}

	function testWithdrawalFunds() public {
		KYC contractKYC = new KYC();

		address addr = this;
		bytes32 hash = 1111111111111111111111111111111111111111111111111111111111111111;
		uint valueNodes = 13;

		contractKYC.changeServerAddr(this);
		contractKYC.createUserInfo(addr, hash, valueNodes);
		contractKYC.userAuthorization.value(100)();

		uint balanceKYC = address(contractKYC).balance;
		Assert.equal(this.balance, initialBalance - 100 - 1, "Invalid balance");
		Assert.equal(balanceKYC, 100, "Invalid balance");

		contractKYC.withdrawalFunds(this, 13);

		uint balanceKYC2 = address(contractKYC).balance;
		Assert.equal(balanceKYC2, 100 - 13, "Invalid balance");
		Assert.equal(this.balance, (initialBalance - 100 - 1) + 13, "Invalid balance");

		contractKYC.withdrawalFunds(this, 0);
		Assert.equal(address(contractKYC).balance, 0, "Invalid balance");
		Assert.equal(this.balance, initialBalance - 1, "Invalid balance");
	}

	function() public payable {}
}
