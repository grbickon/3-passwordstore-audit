// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {PasswordStore} from "../src/PasswordStore.sol";

contract TestUtilities is Test {
    function getOwner(PasswordStore passwordStore) internal view returns (address) {
        bytes32 ownerValue = vm.load(address(passwordStore),bytes32(uint256(0)));
        return address(uint160(uint256(ownerValue)));
    }

    /// @notice Reads a short string (<= 31 bytes) from a given storage slot of a PasswordStore contract
    function getShortPassword(PasswordStore passwordStore, uint256 length) public view returns (string memory result) {
        require(length <= 31, "Length must be <= 31 bytes");
        bytes32 word = vm.load(address(passwordStore), bytes32(uint256(1)));
        bytes memory strBytes = new bytes(length);

        // Copy each byte from the word to the result
        for (uint256 i = 0; i < length; i++) {
            strBytes[i] = word[i];
        }

        result = string(strBytes);
    }
}