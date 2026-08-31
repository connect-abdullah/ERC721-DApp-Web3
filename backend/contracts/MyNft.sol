// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract MyNft {
    mapping(uint256 => address) private owners;
    mapping(address => uint256) private balances;
    mapping(uint256 => address) private tokenApprovals;

    uint256 private nextTokenId;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    function mint() external {
        uint256 tokenId = nextTokenId;

        owners[tokenId] = msg.sender;
        balances[msg.sender]++;
        nextTokenId++;

        emit Transfer(address(0), msg.sender, tokenId);
    }

    function ownerOf(uint256 tokenId) external view returns (address) {
        address owner = owners[tokenId];
        require(owner != address(0), "Token not minted");

        return owner;
    }

    function balanceOf(address owner) external view returns (uint256) {
        require(owner != address(0), "Invalid address");

        return balances[owner];
    }

    function approve(address to, uint256 tokenId) external {
        address owner = owners[tokenId];

        require(owner == msg.sender, "Not owner of token");
        require(owner != address(0), "NFT does not exist");
        require(to != address(0), "Invalid address");

        tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view returns (address) {
        require(owners[tokenId] != address(0), "NFT does not exist");

        return tokenApprovals[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        address owner = owners[tokenId];

        require(owner != address(0), "NFT does not exist");
        require(owner == from, "Wrong owner");
        // if message sender is not an owner, or not in approval list, then show unauthorized.
        require(
            msg.sender == owner ||
            msg.sender == tokenApprovals[tokenId],
            "Not authorized"
        );

        require(to != address(0), "Invalid recipient");
        // change the address to buyer
        owners[tokenId] = to;
        // change the balances
        balances[from]--;
        balances[to]++;
        // make the approval to zero address ( resetting it )
        tokenApprovals[tokenId] = address(0);

        emit Transfer(from, to, tokenId);
    }
}
