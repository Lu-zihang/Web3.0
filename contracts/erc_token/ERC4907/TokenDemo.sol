pragma solidity >= 0.8.0 < 0.9.0;

import "./IERC4907.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TokenDemo is ERC4907 {
    using Strings for uint256; 
    string public  baseUri;
    string public suffix;
    string constant metadata = ".json";

    constructor(
        string memory name_, 
        string memory symbol_,
        string memory _baseUri,
        string memory _suffix
    )  ERC4907(name_,symbol_) {
        baseUri = _baseUri;
        suffix = _suffix;
    }

    function mint(uint tokenId) public {
        _safeMint(msg.sender, tokenId);
    }

    function mintForAddress(uint tokenId, address receiver) public {
        require(receiver != address(0), "The receiver is zero address!");
        _safeMint(receiver, tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string.concat(baseURI, tokenId.toString()) : "";
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }
}
