//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract VulnerableContract2 is ERC721{

    constructor(uint256 _maxSupply) ERC721("0Kage", "0K"){
        s_maxSupply = _maxSupply;
    }
    mapping(address => uint8) s_mintedTokens;
    uint256 s_maxSupply;

    uint256 s_tokensMinted;

    function WhiteListMint(bytes32[] calldata _merkleProof, bytes32 _rootHash, uint256 mintTokens) public {

        // Checks if user already has minted tokens against his/her address
        // this is OK 
        require(s_mintedTokens[msg.sender] <1, "Already minted");

        // Checks if user input for tokens > 0
        // Here is the problem - there is no restriction on number of tokens minted
        // Team expected that user would input small number 
        // Whale can capture entire supply by entering a large amount here
        require(mintTokens >0, "Number of tokens cannot be less than 0");

        // checks if still tokens left
        // this is OK
        require(s_tokensMinted + mintTokens <= s_maxSupply, "All tokens minted");

        // generates current leaf for the sender
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        // checks if lead is part of merkle tree
        // this is used to only ensure that whitelisted participants can mint 
        // this is ok
        require(MerkleProof.verify(_merkleProof, _rootHash, leaf ));

        // user input of mint tokens are going into _safeMint without restriction
        // this was a vulnerability that needed a fix
        // Check out this tweet https://twitter.com/rugpullfinder/status/1565734576630145024
        // for more on what happened
        _safeMint(msg.sender, mintTokens);

    }

    function WhiteListMintCorrected(bytes32[] calldata _merkleProof, bytes32 _rootHash, uint256 mintTokens) public {

        require(s_mintedTokens[msg.sender] <1, "Already minted");
        
        // placed a max cap per address
        require(mintTokens >0 && mintTokens < 5, "Number of tokens cannot be less than 0");

        require(s_tokensMinted + mintTokens <= s_maxSupply, "All tokens minted");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        require(MerkleProof.verify(_merkleProof, _rootHash, leaf ));

        _safeMint(msg.sender, mintTokens);
    }

}