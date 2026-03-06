// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract Sky is ERC721, ERC721URIStorage {
    
     using Strings for uint256;
    // Allows uint256 variables to use the Strings library functions

    uint256 private _nextTokenId;
    // Stores the next token ID that will be minted

  
    mapping(uint256 => uint256) public tokenIdToLevels;
    // Maps each token ID to a level value

    constructor() ERC721("Sky", "SKY") {}
    // Constructor that sets the NFT name ("Sky") and symbol ("SKY")

    // Required overrides
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        // Returns the metadata URI for a given token ID
        return super.tokenURI(tokenId);
        // Calls the parent contract's tokenURI function
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        // Checks whether the contract supports a given interface
        return super.supportsInterface(interfaceId);
        // Calls the parent implementation
    }

    // Generate SVG image
    function generateCharacter(uint256 tokenId) public view returns(string memory){
        // Generates the SVG image for the NFT

        bytes memory svg = abi.encodePacked(
            // Combines multiple pieces of text into a single byte array

            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="red" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">Sky</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">Level: ',

            Strings.toString(tokenIdToLevels[tokenId]),
            // Converts the NFT level number to a string

            '</text>',
            '</svg>'
        );

        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                // Adds the data URI prefix for an SVG image

                Base64.encode(svg)
                // Encodes the SVG image into Base64 format
            )
        );
    }

    // Generate metadata
    function getTokenURI(uint256 tokenId) public view returns (string memory){
        // Creates the metadata JSON for the NFT

        bytes memory dataURI = abi.encodePacked(
            '{',
            // Starts the JSON object

                '"name": "VaultNFT #', tokenId.toString(), '",',
                // Adds the NFT name with its token ID

                '"description": "This is my on-chain NFT",',
                // Adds a description for the NFT

                '"image": "', generateCharacter(tokenId), '"',
                // Adds the Base64 SVG image generated earlier

            '}'
           
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                // Adds the metadata data URI prefix

                Base64.encode(dataURI)
                // Encodes the metadata JSON into Base64
            )
        );
    }

    // Mint NFT
    function mint() external {
        // Allows anyone to mint a new NFT

        _nextTokenId++;
        // Increments the token ID counter

        uint256 newItemId = _nextTokenId;
        // Stores the new token ID

        _safeMint(msg.sender, newItemId);
        // Mints the NFT safely and assigns it to the caller

        tokenIdToLevels[newItemId] = 0;
        // Sets the initial level of the NFT to 0

        _setTokenURI(newItemId, getTokenURI(newItemId));
        // Generates and stores the metadata URI for the NFT
    }
}