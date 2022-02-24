//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
// import "./interfaces/IERC1155Interface.sol";

contract Genesis is ERC721Enumerable, Ownable, ReentrancyGuard {
    /// @dev token id tracker
    uint256 public tokenIdTracker;

    /// @dev Maximum elements
    uint256 CAP = 333;

    /// baseTokenURI
    string public baseTokenURI;

    address public immutable nftOwner =
        0x3B0C7fb36cCf7bB203e5126B2192371Af91831BF;

    address public oldGenesis;

    event Mint(address indexed to, uint256 amount);
    
    event Claim(uint256[] tokenIds);

    event SetBaseTokenURI(string baseTokenURI);

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        address _oldGenesis
    ) ERC721(_name, _symbol) {
        setBaseURI(_baseURI);
        setOldGenesis(_oldGenesis);
    }

    /**
     * @dev Mint NFTs
     */
    function mint(uint256 _amount) external nonReentrant {
        require(_amount > 0, "genesis : mint amount invalid");
        require(tokenIdTracker + _amount <= CAP, "genesis : max limit");

        for (uint256 i = 0; i < _amount; i++) {
            tokenIdTracker += 1;
            _safeMint(nftOwner, tokenIdTracker);
        }

        emit Mint(nftOwner, _amount);
    }

    /**
     * @dev Claim NFT
     */
    function claim(uint256[] memory _tokenIds) external nonReentrant {
        require(_tokenIds.length != 0, "genesis : invalid tokenId length");

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];

            require(tokenId != 0, "genesis : invalid tokenId");

            uint256 count = IERC1155(oldGenesis).balanceOf(msg.sender, tokenId);

            require(count > 0, "genesis : sender is not owner");

            IERC1155(oldGenesis).safeTransferFrom(msg.sender, nftOwner, tokenId, 1, "");
            
            super._safeTransfer(nftOwner, msg.sender, tokenId, "");
        }

        emit Claim(_tokenIds);
    }

    /**
     * @dev Get `baseTokenURI`
     * Overrided
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /**
     * @dev Set `baseTokenURI`
     */
    function setBaseURI(string memory baseURI) public onlyOwner {
        require(bytes(baseURI).length > 0, "genesis : base URI invalid");
        baseTokenURI = baseURI;

        emit SetBaseTokenURI(baseURI);
    }

    function setOldGenesis(address _oldGenesis) public onlyOwner {
        oldGenesis = _oldGenesis;
    }
}