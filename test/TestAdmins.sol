pragma solidity ^0.4.19;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Admins.sol";
import "../contracts/ThrowProxy.sol";

contract TestAdmins {
	function testCreateAdmins() public {
		Admins contractAdmin = new Admins();

		bool isAdmin = contractAdmin.admins(this);
		Assert.equal(isAdmin, true, "Wrong admin address");

		address serverAddress = contractAdmin.serverAddress();
		Assert.equal(serverAddress, 0x0000000000000000000000000000000000000000, "Wrong server address");
	}

	function testAddAdmin() public {
		address newAdmin = 0x1111111111111111111111111111111111111111;

		Admins contractAdmin1 = Admins(DeployedAddresses.Admins());
		ThrowProxy throwProxy = new ThrowProxy(address(contractAdmin1));
		Admins(address(throwProxy)).addAdmin(newAdmin);

		bool result = throwProxy.execute.gas(200000)();
		Assert.equal(result, false, "There was no throw");

		Admins contractAdmin2 = new Admins();
		contractAdmin2.addAdmin(newAdmin);

		bool isAdmin2 = contractAdmin2.admins(newAdmin);
		Assert.equal(isAdmin2, true, "Administrator not added");
	}

	function testAddManyAdmins() public {
		uint countAdmins = 10;

		address[] memory newAdmins = new address[](countAdmins);
		for(uint i = 0; i < countAdmins; i++) {
			newAdmins[i] = address(i);
		}

		Admins contractAdmin = new Admins();

		for(uint j = 0; j < countAdmins; j++) {
			contractAdmin.addAdmin(newAdmins[j]);
		}

		bool isAdmin = false;
		for(uint k = 0; k < countAdmins; k++) {
			isAdmin = contractAdmin.admins(newAdmins[k]);
			Assert.equal(isAdmin, true, "Administrator not added");
		}
	}

	function testChangeServerAddress() public {
		uint countAddresses = 10;

		address[] memory newServers = new address[](countAddresses);
		for(uint i = 0; i < countAddresses; i++) {
			newServers[i] = address(i);
		}

		Admins contractAdmin = new Admins();

		address serverAddress = contractAdmin.serverAddress();
		Assert.equal(serverAddress, 0, "Invalid server address");

		for(uint j = 0; j < countAddresses; j++) {
			contractAdmin.changeServerAddr(newServers[j]);
			serverAddress = contractAdmin.serverAddress();
			Assert.equal(serverAddress, newServers[j], "Invalid server address");
		}
	}
}
