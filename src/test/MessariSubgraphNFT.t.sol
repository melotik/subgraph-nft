// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.14;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {MessariSubgraphNFT} from "../MessariSubgraphNFT.sol";

contract MessariSubgraphNFTTest is DSTestPlus {
    MessariSubgraphNFT subgraphNFT;

    function setUp() public {
        string memory _baseURI = "https://messari.io"; // Fake baseURI
        subgraphNFT = new MessariSubgraphNFT(
            "Messari Subgraph NFT",
            "MSNFT",
            _baseURI
        );
    }

    /*///////////////////////////////////////////////////////////////
                            MINT TESTS
    //////////////////////////////////////////////////////////////*/

    // Test minting with all valid levels
    function testMint() public {
        for (
            uint256 level = subgraphNFT.minLevel();
            level <= subgraphNFT.maxLevel();
            level++
        ) {
            subgraphNFT.mintFor(msg.sender, level);
            uint256 _tokenId = level; // equivalent in this case
            assertEq(subgraphNFT.levelOf(_tokenId), level);
            assertEq(subgraphNFT.balanceOf(address(msg.sender)), level);
            assertEq(subgraphNFT.totalSupply(), level);
        }
    }

    // Test mint higher than maxLevel
    function testCannotMintHighLevel() public {
        vm.expectRevert("Level must be less than or equal to max level.");

        subgraphNFT.mintFor(msg.sender, 6);
    }

    // Test mint lower than minLevel
    function testCannotMintLowLevel() public {
        vm.expectRevert("Level must be greater than or equal to min level.");
        subgraphNFT.mintFor(msg.sender, 0);
    }

    /*///////////////////////////////////////////////////////////////
                            LEVEL UP TESTS
    //////////////////////////////////////////////////////////////*/

    // test level up valid
    function testLevelUp() public {
        subgraphNFT.mintFor(msg.sender, 3);
        uint256 _tokenId = 1;
        subgraphNFT.levelUp(1);
        assertEq(subgraphNFT.levelOf(_tokenId), 4);
    }

    // test level up past max level
    function testCannotLevelUpPastMax() public {
        vm.expectRevert("Level must be less than max level.");

        subgraphNFT.mintFor(msg.sender, 5);
        subgraphNFT.levelUp(1);
        subgraphNFT.levelUp(1);
    }

    // level up non-existant token
    function testLevelUpNonExistant() public {
        vm.expectRevert(abi.encodeWithSignature("TokenDoesNotExist()"));

        subgraphNFT.mintFor(msg.sender, 3);
        subgraphNFT.levelUp(2);
    }

    /*///////////////////////////////////////////////////////////////   
                           TOKEN URI TESTS
    //////////////////////////////////////////////////////////////*/

    function testSetNewTokenURI() public {
        assertEq0(bytes(subgraphNFT.baseURI()), bytes("https://messari.io"));

        // set new URI
        string memory _newURI = "https://dontrugme.io";
        subgraphNFT.setBaseURI(_newURI);
        assertEq0(bytes(subgraphNFT.baseURI()), bytes(_newURI));
    }

    // test getURI for token with level 2
    function testGetURI() public {
        subgraphNFT.mintFor(msg.sender, 2);
        uint256 _tokenId = 1;
        assertEq0(
            bytes(subgraphNFT.tokenURI(_tokenId)),
            bytes("https://messari.io/level2.json")
        );
    }

    // test getURI for token that doesn't exist
    function testGetURIForNonExistant() public {
        vm.expectRevert(abi.encodeWithSignature("TokenDoesNotExist()"));

        uint256 _fakeTokenId = 5;
        subgraphNFT.tokenURI(_fakeTokenId);
    }

    /*///////////////////////////////////////////////////////////////   
                           TOKEN URI TESTS
    //////////////////////////////////////////////////////////////*/

    // test cannot withdraw ether b/c balance is 0
    function testCannotWithdraw() public {
        vm.expectRevert(abi.encodeWithSignature("NoEthBalance()"));

        subgraphNFT.withdraw();
    }
}
