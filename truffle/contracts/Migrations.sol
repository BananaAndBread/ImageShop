// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Migrations {
  address public owner = msg.sender;
  uint public last_completed_migration;

  // ERC-721 interface implementation

  mapping(address => uint256) private balances;
  mapping(address => address[]) private operators;
  mapping(uint256 => address) private approved;
  mapping(uint256 => address) private owners;

  function balanceOf(address _owner) external view returns (uint256) {
    return balances[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    return owners[_tokenId];
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable {
    return this.transferFrom(_from, _to, _tokenId);
    // TODO: check if _to is a contract
  }

  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable {
    return this.safeTransferFrom(_from, _to, _tokenId, "");
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
    require(owners[_tokenId] == msg.sender || approved[_tokenId] == msg.sender || this.isApprovedForAll(owners[_tokenId], msg.sender), "Must be called from an owner");
    require(_from == owners[_tokenId], "Must transfer from the owner");
    require(_to != address(0), "_to must not be zero");

    balances[_from] -= 1;
    balances[_to] += 1;
    owners[_tokenId] = _to;
  }

  function approve(address _approved, uint256 _tokenId) external payable {
    require(owners[_tokenId] == msg.sender || this.isApprovedForAll(owners[_tokenId], msg.sender), "Must be called from an owner");
    approved[_tokenId] = _approved;
  }

  function setApprovalForAll(address _operator, bool _approved) external {
    if (_approved && !this.isApprovedForAll(msg.sender, _operator)) {
      operators[msg.sender].push(_operator);
    } else if (!_approved && this.isApprovedForAll(msg.sender, _operator)) {
      int256 idx = -1;
      for (uint256 i = 0; i < operators[msg.sender].length; i++) {
        if (operators[msg.sender][i] == _operator) {
          idx = int256(i);
          break;
        }
      }
      if (idx >= 0) {
        uint256 uidx = uint256(idx);
        operators[msg.sender][uidx] = operators[msg.sender][operators[msg.sender].length - 1];
        operators[msg.sender].pop();
      }
    }
  }

  function getApproved(uint256 _tokenId) external view returns (address) {
    return approved[_tokenId];
  }

  function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
    for (uint256 i = 0; i < operators[_owner].length; i++) {
      if (operators[_owner][i] == _operator) {
        return true;
      }
    }
    return false;
  }

  // Actual logic

  struct Image {
    bool is_claimed;

    string title;
    bytes content;
  }

  uint256[] private all_tokens;
  uint256 next_image = 1;
  mapping(uint256 => Image) public images;

  function buyImage (string calldata _title, bytes calldata _content) external payable {
    require(next_image < 1001, "At most 1000 images are allowed");
    require(msg.value == 1 ether, "Pay 1 ether to buy an image");

    images[next_image].is_claimed = true;
    images[next_image].title = _title;
    images[next_image].content = _content;
    owners[next_image] = msg.sender;
    balances[msg.sender] += 1;
    next_image += 1;
  }

  function modifyImage (uint256 _tokenId, string calldata _title, bytes calldata _content) external {
    require(owners[_tokenId] == msg.sender, "Must be an owner");

    images[_tokenId].title = _title;
    images[_tokenId].content = _content;
  }

  modifier restricted() {
    require(
      msg.sender == owner,
      "This function is restricted to the contract's owner"
    );
    _;
  }

  function setCompleted(uint completed) public restricted {
    last_completed_migration = completed;
  }
}
