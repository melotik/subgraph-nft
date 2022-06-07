
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.14;

import {DSTest} from "./test.sol";
import {ERC20} from "@rari-capital/solmate/src/tokens/ERC20.sol";

import {StdCheatsTest, StdErrorsTest} from "./stdlib.sol";
import {Vm} from "./Vm.sol";

contract DSTestPlus is DSTest, stdCheats {
    /// @dev Use forge-std Vm logic
    Vm public constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function assertERC20Eq(ERC20 erc1, ERC20 erc2) internal {
        assertEq(address(erc1), address(erc2));
    }
}