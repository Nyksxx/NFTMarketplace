// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTMarketplace is ERC721URIStorage {
    error notEnoughETHForList();
    error ValueCantBeZero();

    address payable owner;

    using Counters for Counters.Counter;

    Counter.counter private _tokenId;
    Counter.counter private _itemSold;

    uint256 listPrice = 0.01 ether;

    constructor() ERC721("NFT Marketplace", "NFTM") {
        owner = payable(msg.sender);
    }

    struct ListedToken {
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool currentlyListed;
    }

    mapping(address => ListedToken) idToListedToken;

    modifier onlyOwner() {
        if (msg.sender != owner) revert();
        _;
    }

    function updateListPrice(uint256 _newListPrice) public onlyOwner {
        listPrice = _newListPrice;
    }

    function getListPrice() public view returns (uint256) {
        return listPrice;
    }

    function getLatestIdToListedToken()
        public
        view
        returns (ListedToken memory)
    {
        uint256 currentTokenId = _tokenId.current();
        return idToListedToken[currentTokenId];
    }

    function getListedForTokenId(uint256 tokenId)
        public
        view
        returns (ListedToken memory)
    {
        return idToListedToken[tokenId];
    }

    function getCurrentToken() public view returns (uint256) {
        return _tokenId.current();
    }

    function getAllNFTs() public view returns (ListedToken[] memory) {
        uint256 nftCount = _tokenId.current();
        ListedToken[] memory tokens = new ListedToken[](nftCount);

        uint256 currentIndex = 0;

        for(uint256 i = 0; i < nftCount; i++) {
            uint currentId++;
            ListedToken storage currentItem = idToListedToken[currentId];
            tokens[currentIndex] = currentItem;
            currentItem++;

        }
        return tokens;
    }

    function createToken(string memory tokenUri, uint256 price)
        public
        payable
        returns (uint256)
    {
        if (msg.value < listPrice) {
            revert notEnoughETHForList();
        }
        if (msg.value == 0) {
            revert ValueCantBeZero();
        }
        _tokenId.increment();
        uint256 currentTokenId = _tokenId.current();

        _safeMint(msg.sender, currentTokenId);

        _setTokenURI(currentTokenId, tokenUri);

        createListedToken(currentTokenId, price);

        return currentTokenId;
    }

    function createListedToken(uint256 tokenId, uint256 price) private {
        idToListedToken[tokenId] = ListedToken(
            tokenId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );
        _transfer(msg.sender, address(this), tokenId);
    }
}
