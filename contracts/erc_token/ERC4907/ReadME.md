# Overview

### Abstruct 
This standard is an extension of EIP-721. It proposes an additional role (user) which can be granted to addresses, and a time where the role is automatically revoked (expires). The user role represents permission to "use" the NFT, but not the ability to transfer it or set users.


&nbsp;

&nbsp; 

### Clear Rights Assignment
&nbsp; &nbsp; With Dual “owner” and “user” roles, it becomes significantly easier to manage what lenders and borrowers can and cannot do with the NFT (in other words, their rights). Additionally, owners can control who the user is and it’s easy for other projects to assign their own rights to either the owners or the users.

&nbsp;

### Simple On-chain Time Management
&nbsp; &nbsp; Once a rental period is over, the user role needs to be reset and the “user” has to lose access to the right to use the NFT. This is usually accomplished with a second on-chain transaction but that is gas inefficient and can lead to complications because it’s imprecise. With the expires function, there is no need for another transaction because the “user” is invalidated automatically after the duration is over.

&nbsp;

### Easy Third-Party Integration
&nbsp; &nbsp; In the spirit of permission less interoperability, this standard makes it easier for third-party protocols to manage NFT usage rights without permission from the NFT issuer or the NFT application. Once a project has adopted the additional user role and expires, any other project can directly interact with these features and implement their own type of transaction. For example, a PFP NFT using this standard can be integrated into both a rental platform where users can rent the NFT for 30 days AND, at the same time, a mortgage platform where users can use the NFT while eventually buying ownership of the NFT with installment payments. This would all be done without needing the permission of the original PFP project.

&nbsp;

---

## Usage

### **Example**
Implement NFT authorization to other user roles with expiration times by inheriting ERC4901.sol.

&nbsp;

```Solidity
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
```
