/// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {TestUtilities} from "../test/TestUtilities.sol";
import {PasswordStore} from "../src/PasswordStore.sol";
import {Handler} from "../test/Handler.t.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployPasswordStore} from "../script/DeployPasswordStore.s.sol";

contract Invariants is StdInvariant, TestUtilities {
    PasswordStore public passwordStore;
    DeployPasswordStore public deployer;
    address public owner;
    address public nonOwner;

    Handler public handler;


    function setUp() public {
        deployer = new DeployPasswordStore();
        passwordStore = deployer.run();
        owner = msg.sender;
        nonOwner = address(0xCAFE);
        handler = new Handler(passwordStore);
        targetSender(owner);
        targetSender(nonOwner);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = Handler.setPassword.selector;
        FuzzSelector memory selector = FuzzSelector({
            addr: address(handler),
            selectors: selectors
        });
        targetSelector(selector);
    }

    function invariant_ownerNeverChanges() public {
        assertEq(owner, getOwner(passwordStore));
    }

    function invariant_ownerCanAlwaysGetPassword() public {
        vm.prank(owner);
        passwordStore.getPassword();
    }
}
