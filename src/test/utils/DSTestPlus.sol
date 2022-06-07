// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.14;

import {DSTest} from "@ds/test.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";

import {Test} from "@std/Test.sol";
import {Vm} from "@std/Vm.sol";

contract DSTestPlus is DSTest, Test {
    
    function assertERC20Eq(ERC20 erc1, ERC20 erc2) internal {
        assertEq(address(erc1), address(erc2));
    }
}