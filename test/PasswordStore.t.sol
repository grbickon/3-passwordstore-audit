/// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {TestUtilities} from "../test/TestUtilities.sol";
import {PasswordStore} from "../src/PasswordStore.sol";
import {DeployPasswordStore} from "../script/DeployPasswordStore.s.sol";

contract PasswordStoreTest is TestUtilities {
    PasswordStore public passwordStore;
    DeployPasswordStore public deployer;
    address public owner;

    function setUp() public {
        deployer = new DeployPasswordStore();
        passwordStore = deployer.run();
        owner = msg.sender;
    }

    function test_setUpState() public {
        vm.prank(owner);
        assertEq('', passwordStore.getPassword());
    }

    modifier setPassword(address addr,string memory password) {
        vm.prank(addr);
        passwordStore.setPassword(password);
        _;
    }

    function testFuzz_ownerCanSetAndGetPassword(string memory expectedPassword) public setPassword(owner, expectedPassword) {
        vm.prank(owner);
        string memory actualPassword = passwordStore.getPassword();

        assertEq(expectedPassword, actualPassword);
    }

    function testFuzz_nonOwnerCannotGetPassword(address addr) public {
        vm.assume(addr != owner);
        vm.prank(addr);
        vm.expectRevert(PasswordStore.PasswordStore__NotOwner.selector);
        string memory actualPassword = passwordStore.getPassword();
    }

    function testFuzz_anybodyCanSetPassword(address addr, string memory expectedPassword) public setPassword(addr, expectedPassword) {
        vm.prank(owner);
        string memory actualPassword = passwordStore.getPassword();

        assertEq(expectedPassword, actualPassword);
    }

    function test_privateOwnerCanBeSeenByEveryone() public {
        assertEq(owner, getOwner(passwordStore));
    }

    function testFuzz_privatePasswordCanBeSeenByEveryone(string memory expectedPassword) public setPassword(owner, expectedPassword) {
        // https://docs.soliditylang.org/en/v0.8.18/internals/layout_in_storage.html#bytes-and-string
        uint256 length = bytes(expectedPassword).length;
        vm.assume(length < 32);

        bytes32 mainSlotValue = vm.load(address(passwordStore),bytes32(uint256(1)));
        bool isLongArray = length > 31;
        // short array: lowest bit is not set, long array: lowest bit is set
        assertEq(bytes32(abi.encode(isLongArray)), mainSlotValue & bytes32(uint256(1)));
        if (isLongArray) {
            // if the date is 32 or more bytes long
            // the main slot stores length * 2 + 1
            assertEq(uint256(mainSlotValue),(length*2)+1);
            // HAVE NOT FIGURED OUT READING PASSWORD STRING FROM STORAGE
            // assertEq(expectedPassword, getLongPassword(passwordStore, length));
        } else {
            bytes32 mainSlotLowestOrderByte = mainSlotValue & bytes32(uint256(255));
            // if the data is at most 31 bytes long
            // the elements are stored in the higher-order bytes (left aligned)
            // and the lowest-order byte stores the value length * 2
            assertEq(uint256(mainSlotLowestOrderByte), length*2);
            assertEq(expectedPassword, getShortPassword(passwordStore, length));
        }
    }
}