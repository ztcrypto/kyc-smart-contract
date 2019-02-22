pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/KYC.sol";
import "../contracts/ThrowProxy.sol";

contract TestKYCBasic {
    
    uint public initialBalance = 1000 wei;

    function testCreateKYC() public {
        KYC contractKYC = new KYC();

        bool isAdmin = contractKYC.admins(this);
        Assert.equal(isAdmin, true, "Wrong admin address");

        address serverAddress = contractKYC.serverAddress();
        Assert.equal(serverAddress, 0x0000000000000000000000000000000000000000, "Wrong server address");
    }

    function testUserAuthorization() public {
        KYC contractKYC = new KYC();

        ThrowProxy throwProxy = new ThrowProxy(address(contractKYC));

        address addr = this;
        string memory hash = "1111111111111111111111111111111111111111111111111111111111111111";
        uint valueNodes = 13;

        contractKYC.changeServerAddr(this);
        contractKYC.createUserInfo(addr, hash, valueNodes);

        (string memory hashInfo, uint nodesInfo, bool validInfo) = contractKYC.informations(addr);
        Assert.equal(hashInfo, hash, "Invalid hashData");
        Assert.equal(nodesInfo, valueNodes, "Invalid valueNodes");
        Assert.equal(validInfo, false, "Invalid valid");

        KYC(address(throwProxy)).userAuthorization();

        bool result1 = throwProxy.execute.gas(200000)();
        Assert.equal(result1, false, "There was no throw");

        contractKYC.userAuthorization.value(1)();
        (string memory hashInfo2, uint nodesInfo2, bool validInfo2) = contractKYC.informations(addr);
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
        string memory hash = "1111111111111111111111111111111111111111111111111111111111111111";
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
