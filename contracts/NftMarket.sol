// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NftMarket is ERC721URIStorage {
    using Counters for Counters.Counter;

    struct NftItem {
        uint256 tokenId;
        uint256 price;
        address creator;
        bool isListed;
    }

    uint256 public listingPrice = 0.025 ether;

    Counters.Counter private _listedItems;
    Counters.Counter private _tokenIds;

    mapping(string => bool) private _usedTokenURIs;
    mapping(uint256 => NftItem) private _idToNftItem;

    event NftItemCreated(
        uint256 tokenId,
        uint256 price,
        address creator,
        bool isListed
    );

    constructor() ERC721("CreaturesNFT", "CNFT") {}

    function getNftItem(uint256 tokenId) public view returns (NftItem memory) {
        return _idToNftItem[tokenId];
    }

    function listedItemsCount() public view returns (uint256) {
        return _listedItems.current();
    }

    function tokenURIExists(string memory tokenURI) public view returns (bool) {
        return _usedTokenURIs[tokenURI] == true;
    }

    function mintToken(string memory tokenURI, uint256 price)
        public
        payable
        returns (uint256)
    {
        require(!tokenURIExists(tokenURI), "Token URI already exists");
        require(
            msg.value == listingPrice,
            "Price must be equal to listing price"
        );

        _tokenIds.increment();
        _listedItems.increment();

        uint256 newTokenId = _tokenIds.current();

        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        _createNftItem(newTokenId, price);
        _usedTokenURIs[tokenURI] = true;

        return newTokenId;
    }

    function _createNftItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price must be at least 1 wei");

        _idToNftItem[tokenId] = NftItem(tokenId, price, msg.sender, true);

        emit NftItemCreated(tokenId, price, msg.sender, true);
    }
}
