/*
 __    __     ______     ______     ______     ______     ______     __
/\ "-./  \   /\  ___\   /\  ___\   /\  ___\   /\  __ \   /\  == \   /\ \
\ \ \-./\ \  \ \  __\   \ \___  \  \ \___  \  \ \  __ \  \ \  __<   \ \ \
 \ \_\ \ \_\  \ \_____\  \/\_____\  \/\_____\  \ \_\ \_\  \ \_\ \_\  \ \_\
  \/_/  \/_/   \/_____/   \/_____/   \/_____/   \/_/\/_/   \/_/ /_/   \/_/
*/

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.14;

import {ERC721} from "@rari-capital/solmate/src/tokens/ERC721.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeTransferLib} from "@rari-capital/solmate/src/utils/SafeTransferLib.sol";

error TokenDoesNotExist();
error NoEthBalance();

/// @title Subgraph NFT Airdrop
/// @title SubgraphNFT
/// @author Dylan Melotik <@dylanmelotik>
contract SubgraphNFT is ERC721, Ownable {
    using Strings for uint256;

    uint256 private _maxLevel = 5;
    uint256 public totalSupply = 0;
    string public baseURI;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Creates an NFT Drop
    /// @param _name The name of the token.
    /// @param _symbol The Symbol of the token.
    /// @param _baseURI The baseURI for the token that will be used for metadata.
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI
    ) ERC721(_name, _symbol) {
        baseURI = _baseURI;
    }

    /*///////////////////////////////////////////////////////////////
                               MINT FUNCTION
    //////////////////////////////////////////////////////////////*/

    /// @notice Mint NFT function.
    /// @param receiver Address of the new owner of the minted NFT
    /// @param level The level this NFT will be when minted
    function mintFor(address receiver, uint256 level) external onlyOwner {
        require(
            level <= _maxLevel,
            "Level must be less than or equal to max level."
        );

        unchecked {
            uint256 tokenId = totalSupply + 1;
            _mint(receiver, tokenId);
            _levelOf[tokenId] = level;
            totalSupply++;
        }
    }

    /*///////////////////////////////////////////////////////////////
                              LEVEL UP 
    //////////////////////////////////////////////////////////////*/

    /// @notice Maps token id to level
    mapping(uint256 => uint256) private _levelOf;

    /// @notice gives the level of a given tokenId
    function levelOf(uint256 tokenId) public view virtual returns (uint256) {
        if (_ownerOf[tokenId] == address(0)) {
            revert TokenDoesNotExist();
        }

        return _levelOf[tokenId];
    }

    /// @notice increases the level of a given NFT
    function levelUp(uint256 tokenId) external onlyOwner {
        require(
            _levelOf[tokenId] < _maxLevel,
            "Level must be less than or equal to max level."
        );
        if (_ownerOf[tokenId] == address(0)) {
            revert TokenDoesNotExist();
        }

        unchecked {
            _levelOf[tokenId]++;
        }
    }

    /*///////////////////////////////////////////////////////////////
                            URI Functions
    //////////////////////////////////////////////////////////////*/

    /// @notice sets a new base URI for the NFT animation
    /// @param _baseURI The baseURI for the token that will be used for metadata
    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        if (_ownerOf[tokenId] == address(0)) {
            revert TokenDoesNotExist();
        }

        return
            bytes(baseURI).length > 0
                ? string(
                    abi.encodePacked(
                        baseURI,
                        "/level",
                        _levelOf[tokenId].toString(),
                        ".json"
                    )
                )
                : "";
    }

    /*///////////////////////////////////////////////////////////////
                            ETH WITHDRAWAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Withdraw all ETH from the contract to the vault addres.
    function withdraw() external onlyOwner {
        if (address(this).balance == 0) revert NoEthBalance();
        SafeTransferLib.safeTransferETH(owner(), address(this).balance);
    }
}
