pragma solidity ^0.4.17;

contract Admins {

	mapping (address => bool) public admins;

	address public serverAddress;

	function Admins() public {admins[msg.sender] = true;}

	event AddAdmin(address newAdmin);
	event RemoveAdmin(address adminAdress);
	event ChangeServerAddr(address oldAddress, address newAddress);

	function removeAdmin(address a) external onlyAdmin {
		admins[a] = false;
		RemoveAdmin(a);
	}

	function addAdmin(address a) external onlyAdmin {
		admins[a] = true;
		AddAdmin(a);
	}

	function changeServerAddr(address newAddress) external onlyAdmin {
		ChangeServerAddr(serverAddress, newAddress);
		serverAddress = newAddress;
	}

	modifier onlyAdmin {
		require(admins[msg.sender]);
		_;
	}

	modifier onlyServer {
		require(msg.sender == serverAddress);
		_;
	}
}

