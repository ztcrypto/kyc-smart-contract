pragma solidity ^0.4.17;

import "./admins.sol";

contract KYC is Admins {

    struct UserInfo {
        bytes32 hashData;
        uint valueNodes;
        bool valid;
    }

    mapping(address => UserInfo) public informations;

    function createUserInfo(address user, bytes32 hashData, uint valueNodes) external onlyServer {
        assert(informations[user].hashData == 0 && hashData != 0);
        assert(informations[user].valueNodes == 0 && valueNodes > 0);
        assert(informations[user].valid == false);

        informations[user] = UserInfo(hashData, valueNodes, false);
    }

    function changeUserInfo(address user, bytes32 hashData, uint valueNodes) external onlyServer {
        assert(informations[user].hashData != 0);
        assert(informations[user].valueNodes > 0 );

        informations[user] = UserInfo(hashData, valueNodes, false);
    }

    function userAuthorization() external payable {
        assert(informations[msg.sender].hashData != 0);
        assert(informations[msg.sender].valueNodes > 0 );
        assert(informations[msg.sender].valid == false);
        assert(informations[msg.sender].valueNodes < (msg.value * 100));

        informations[msg.sender].valid = true;
    }

    function isAuthorized(address user) external constant returns(bool) {
        assert(informations[user].hashData != 0);
        assert(informations[user].valueNodes > 0 );

        return informations[user].valid;
    }

    function withdrawalFunds(address addr, uint amount) external onlyAdmin {
        if(amount != 0) {
            addr.transfer(amount);
        } else {
            addr.transfer(this.balance);
        }
    }
}

