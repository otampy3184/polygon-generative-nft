//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../node_modules/hardhat/console.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

// Collectible NFTをMintするコントラクト
contract NFTCollectible is ERC721Enumerable, Ownable {
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    // そう供給量、価格、取引当たりの最大Mint量を定義
    uint public constant MAX_SUPPLY = 30;
    uint public constant PRICE = 0.01 ether;
    uint public constant MAX_PER_MINT = 3;

    // Metadataを格納したIPFSのCID付きURI
    string public baseTokenURI;

    // ConstructorでbaseTokenURIを確定させる
    constructor(string memory baseURI) ERC721("NFT Collectible", "NFTCL"){
        setBaseURI(baseURI);
    }

    // 無料配布用のNFTを10個用意する
    function reserveNFTs() public onlyOwner {
        uint totalMinted = _tokenIds.current();
        // 10個分のNFTが残っているかどうかを確認する
        require(
            totalMinted.add(10) < MAX_SUPPLY, "Not Enough NFTs"
        );
        // 10個のNFTをMintする
        for (uint i = 0; i < 10; i++){
            _mintSingleNFT();
        }
    }

    function _baseURI() internal view virtual override returns (string memory){
        return baseTokenURI;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner{
        baseTokenURI = _baseTokenURI;
    }

    // ユーザーが有料でNFTをMintできる関数
    function mintNFTs(uint _count) public payable {
        uint totalMinted = _tokenIds.current();
        // Mint分のNFTは残っているか？
        require(totalMinted.add(_count) <= MAX_SUPPLY, "Not enough NFTs");

        // Mint数が0でなく、かつ最大数も超えていないか？
        require(_count > 0 && _count <= MAX_PER_MINT, "Cannot mint specified number of NFTs");

        // ユーザーは十分なEtherを持っているか？
        require(msg.value >= PRICE.mul(_count), "Not enough ether to purchase NFTs");

        // Count分Mintを実行
        for(uint i = 0; i < _count; i++ ){
            _mintSingleNFT();
        }
    }

    // NFTを新規で１個Mintする
    function _mintSingleNFT() private {
        uint newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        _tokenIds.increment();
    }

    // ユーザーの所有NFTのリストを返す
    function tokensOfOwner(address _owner) external view returns (uint[] memory){
        // OwnerアドレスのToken所有数確認
        uint tokenCount = balanceOf(_owner);
        // 所有数分の長さを持ち、Uint(=tokenId)を格納する配列の入れ物
        uint[] memory tokenId = new uint256[](tokenCount);
        // 一つ一つ埋めていく
        for (uint i = 0; i < tokenCount; i ++){
            tokenId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenId;
    }

    // 稼いだEtherを引き出す
    function withdraw() public payable onlyOwner {
        // このコントラクトに送られたEtherを確認
        uint balance = address(this).balance;
        // 引き出すためのEtherは残っているか？
        require(balance > 0, "No ether left to withdraw");
        // SenderにコントラクトのEtherを送金
        (bool success, ) = (msg.sender).call{value: balance}("");
        require(success, "withdraw failed");
    }
}
