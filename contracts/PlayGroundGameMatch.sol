// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

error SignatureMismatch();
error NonceAlreadyUsed();

contract PlaygroundGameMatch is OwnableUpgradeable, UUPSUpgradeable {
    mapping(string => mapping(address => uint256)) public completedMatch; // completedMatch[gameId][msg.sender] = timestamp

    event MatchCompleted(address indexed _userAddress, string _gameId);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
    }

    function completeMatch(string calldata _gameId) public {
        require(
            completedMatch[_gameId][_msgSender()] == 0,
            "PlayGround GameMatch: match already completed"
        );

        completedMatch[_gameId][_msgSender()] = block.timestamp;

        emit MatchCompleted(_msgSender(), _gameId);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
