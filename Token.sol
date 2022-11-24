pragma solidity ^0.8.1;

// SPDX-License-Identifier: MIT


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Sample NFT contract
 * @dev Extends ERC-721 NFT contract and implements ERC-2981
 */

contract Token is Ownable, ERC721, ERC721URIStorage {

    // Keep a mapping of token ids and corresponding IPFS hashes
    mapping(string => uint8) hashes;
    // Maximum amounts of mintable tokens
    uint256 public _maxSupply;

    uint256 public _price;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenSupply;

    bool mintAvailable = true;

    string baseUri = "www.google.pl";

    IERC20 usdcToken = IERC20(0x7F38656a07c54249819C4a7a802954f0e05cd6DE);
    //100 USDC = 100000000
    // 10 usdc = 10000000


    // Events
    event Mint(uint256 tokenId, address recipient);

    constructor(uint256 maxSupply, string memory name, string memory tag, uint256 price) ERC721(name, tag) {
        _maxSupply = maxSupply;
        _price = price;
    }

    /** Overrides ERC-721's _baseURI function */
    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }




    function _burn(uint256 tokenId)
    internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    /// @notice Returns a token's URI
    /// @dev See {IERC721Metadata-tokenURI}.
    /// @param tokenId - the id of the token whose URI to return
    /// @return a string containing an URI pointing to the token's ressource
    function tokenURI(uint256 tokenId)
    public view override(ERC721, ERC721URIStorage)
    returns (string memory) {
        return super.tokenURI(tokenId);
    }


    function mint(address recipient, string[] memory hash)
    external
    returns (uint256[10] memory tokensIds)
    {
        require(mintAvailable, "Mint is stopped");
        require(_tokenSupply.current() < _maxSupply, "All tokens minted");
        usdcToken.transferFrom(msg.sender, owner(), _price * hash.length);
        for(uint256 i = 0; i< hash.length; i++){
                tokensIds[i] = mintToken(recipient, hash[i]);
        }
        
        return tokensIds;
    }

    function mintToken(address recipient, string memory hash)
    internal
    returns (uint256 tokenId)
    {
        require(_tokenSupply.current() < _maxSupply, "All tokens minted");
        require(bytes(hash).length > 0); // dev: Hash can not be empty!
        require(bytes(hash).length > 0); // dev: add checking uniq
        uint256 newItemId = _tokenSupply.current() + 1;
        _tokenSupply.increment();
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, hash);
        emit Mint(newItemId, recipient);
        return newItemId;
    }


    function tokensMinted() public view returns (uint256) {
        return _tokenSupply.current();
    }

    function setMintStatus(bool status)
    external  onlyOwner {
        mintAvailable = status;
    }

    function setBaseURI(string memory uri)
    external  {
        baseUri = uri;
    }

}
