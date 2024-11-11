// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import { MyToken } from './MyToken.sol';

contract WrappedMyToken is MyToken {
    constructor(string memory tokenName, string memory tokenSymbol)
    MyToken(tokenName, tokenSymbol)

    function mintTokenWithSecificTokenId(address to, uint256 tokenId) public {
        // more contorllable
        _safeMint(to, tokenId);
    }

}