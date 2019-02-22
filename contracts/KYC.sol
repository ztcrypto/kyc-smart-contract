pragma solidity ^0.4.24;

import "./Admins.sol";

contract KYC is Admins {

    struct UserInfo {
        string hashData;
        uint valueNodes;
        bool valid;
    }

    mapping(address => UserInfo) public informations;

    event CreateUserInfo(address user, string hashData, uint valueNodes);
    event ChangeUserInfo(address user, string hashData, uint valueNodes);
    event UserAuthorization(address user);
    event WithdrawalFunds(address addr, uint amount);

    function createUserInfo(address user, string hashData, uint valueNodes) external onlyServer {
        require(bytes(informations[user].hashData).length == 0 && bytes(hashData).length != 0);
        require(informations[user].valueNodes == 0 && valueNodes > 0);
        require(informations[user].valid == false);

        informations[user] = UserInfo(hashData, valueNodes, false);

        CreateUserInfo(user, hashData, valueNodes);
    }

    function changeUserInfo(address user, string hashData, uint valueNodes) external onlyServer {
        require(bytes(informations[user].hashData).length != 0);
        require(informations[user].valueNodes > 0 );

        informations[user] = UserInfo(hashData, valueNodes, false);

        ChangeUserInfo(user, hashData, valueNodes);
    }

    function userAuthorization() external payable {
        require(bytes(informations[msg.sender].hashData).length != 0);
        require(informations[msg.sender].valueNodes > 0 );
        require(informations[msg.sender].valid == false);
        require(informations[msg.sender].valueNodes <= (msg.value * 100));

        informations[msg.sender].valid = true;

        UserAuthorization(msg.sender);
    }

    function isAuthorized(address user) external constant returns(bool) {
        require(bytes(informations[user].hashData).length != 0);
        require(informations[user].valueNodes > 0 );

        return informations[user].valid;
    }

    function withdrawalFunds(address addr, uint amount) external onlyAdmin {

        uint summ = 0;
        if(amount != 0) {
            require(this.balance >= amount);
            summ = amount;
        } else {
            summ = this.balance;
        }
        addr.transfer(summ);

        WithdrawalFunds(addr, summ);
    }
}

