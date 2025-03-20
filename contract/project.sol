// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract NFTArtMarketplace {
    uint256 private _tokenIds;

    struct NFT {
        uint256 tokenId;
        address creator;
        uint256 price;
        bool forSale;
    }

    mapping(uint256 => NFT) public nfts;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;

    event NFTMinted(uint256 tokenId, address creator, string tokenURI);
    event NFTForSale(uint256 tokenId, uint256 price);
    event NFTSold(uint256 tokenId, address buyer, uint256 price);

    modifier onlyOwner(uint256 tokenId) {
        require(_owners[tokenId] == msg.sender, "You are not the owner");
        _;
    }

    function mintNFT(string memory tokenURI, uint256 price) external {
        require(price > 0, "Price must be greater than zero");
        _tokenIds++;
        uint256 newTokenId = _tokenIds;

        _owners[newTokenId] = msg.sender;
        _balances[msg.sender]++;

        nfts[newTokenId] = NFT({
            tokenId: newTokenId,
            creator: msg.sender,
            price: price,
            forSale: true
        });

        emit NFTMinted(newTokenId, msg.sender, tokenURI);
    }

    function buyNFT(uint256 tokenId) external payable {
        NFT storage nft = nfts[tokenId];
        require(nft.forSale, "This NFT is not for sale");
        require(msg.value >= nft.price, "Insufficient funds");

        address seller = _owners[tokenId];
        _owners[tokenId] = msg.sender;
        _balances[seller]--;
        _balances[msg.sender]++;

        nft.forSale = false;
        payable(seller).transfer(msg.value);

        emit NFTSold(tokenId, msg.sender, msg.value);
    }

    function listNFTForSale(uint256 tokenId, uint256 price) external onlyOwner(tokenId) {
        require(price > 0, "Price must be greater than zero");

        nfts[tokenId].forSale = true;
        nfts[tokenId].price = price;

        emit NFTForSale(tokenId, price);
    }

    function withdrawFunds() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}
