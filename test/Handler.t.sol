/// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {TestUtilities} from "../test/TestUtilities.sol";
import {PasswordStore} from "../src/PasswordStore.sol";
import {DeployPasswordStore} from "../script/DeployPasswordStore.s.sol";

contract Handler is TestUtilities {
    PasswordStore public passwordStore;
    DeployPasswordStore public deployer;

    constructor(PasswordStore _passwordStore) {
        passwordStore = _passwordStore;
    }

    function setPassword(string memory newPassword) public {
        // only owner can set password
        if (msg.sender != getOwner(passwordStore)) {
            revert PasswordStore.PasswordStore__NotOwner();
        }
        passwordStore.setPassword(newPassword);
    }
}